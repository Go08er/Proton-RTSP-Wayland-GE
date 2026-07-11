#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOL_DIR="${1:-}"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

require_file() {
  [[ -s "$TOOL_DIR/$1" ]] || fail "missing or empty artifact: $1"
}

[[ -n "$TOOL_DIR" ]] || fail "usage: $0 /path/to/Proton-RTSP-11.1-Wayland-GE"
[[ -d "$TOOL_DIR" ]] || fail "tool directory does not exist: $TOOL_DIR"

require_file proton
require_file compatibilitytool.vdf
require_file version
require_file files/bin/xrandr
require_file files/lib/wine/x86_64-unix/winewayland.so
require_file files/lib/wine/i386-unix/winewayland.so
require_file files/lib/wine/x86_64-windows/winewayland.drv
require_file files/lib/wine/i386-windows/winewayland.drv
require_file files/lib/wine/x86_64-unix/winegstreamer.so
require_file files/lib/wine/i386-unix/winegstreamer.so
require_file files/share/X11/locale/compose.dir
require_file files/share/X11/locale/locale.dir
require_file files/share/X11/locale/en_US.UTF-8/Compose
require_file files/share/default_pfx/system.reg
require_file LICENSE
require_file LICENSE.proton
require_file LICENSE.upstream-proton
require_file LICENSE.wine
require_file COPYING.LIB.wine
require_file NOTICE.md
require_file SOURCE.md
require_file licenses/README.md
require_file licenses/COMPONENTS.md
require_file licenses/manifest.sha256
require_file licenses/X11-locale-COPYING
require_file licenses/xrandr-COPYING
require_file licenses/Xalia-LICENSE
require_file licenses/Xalia-SDL3-LICENSE
require_file licenses/Xalia-Superpower-LICENSE
require_file licenses/Xalia-Tmds.DBus.Protocol-LICENSE
require_file licenses/Xalia-dotnet-runtime-THIRD-PARTY-NOTICES
require_file licenses/espeak-ng-COPYING
require_file licenses/onnxruntime-LICENSE
require_file licenses/onnxruntime-ThirdPartyNotices
require_file licenses/upstream/wine/COPYING.LIB
require_file licenses/upstream/dxvk/LICENSE
require_file licenses/upstream/dxvk-nvapi/LICENSE
require_file licenses/upstream/vkd3d/COPYING
require_file licenses/upstream/vkd3d-proton/COPYING
require_file licenses/upstream/gstreamer/LICENSE
require_file licenses/upstream/ffmpeg/LICENSE.md
require_file licenses/upstream/OpenXR-SDK/LICENSE
require_file licenses/upstream/openvr/LICENSE
require_file licenses/upstream/lsteamclient/LICENSE
require_file licenses/upstream/piper/LICENSE.md
require_file licenses/upstream/vosk-api/COPYING
require_file licenses/upstream/kaldi/COPYING
require_file licenses/upstream/openfst/COPYING
require_file licenses/upstream/external/piper-phonemize/LICENSE.md
require_file licenses/upstream/external/espeak-ng/COPYING
require_file licenses/upstream/external/xrandr/COPYING

[[ -x "$TOOL_DIR/proton" ]] || fail "Proton launcher is not executable"
[[ -x "$TOOL_DIR/files/bin/xrandr" ]] || fail "bundled xrandr is not executable"

grep -Fq 'Proton-RTSP-Wayland-GE contributors' "$TOOL_DIR/LICENSE" \
  || fail "project BSD-3-Clause license is not installed"
grep -Fq 'Valve Corporation' "$TOOL_DIR/LICENSE.proton" \
  || fail "upstream Proton license is not installed"
grep -Fiq 'GNU LESSER GENERAL PUBLIC LICENSE' "$TOOL_DIR/COPYING.LIB.wine" \
  || fail "Wine LGPL text is not installed"
grep -Fq 'Proton-RTSP-11.1-Wayland-GE-source.tar.gz' "$TOOL_DIR/SOURCE.md" \
  || fail "corresponding-source archive is not named"
! grep -Fq 'refs/heads/pic.zip' "$TOOL_DIR/SOURCE.md" \
  || fail "SOURCE.md references a mutable piper-phonemize URL"
! rg -n 'TODO|TBD' "$TOOL_DIR/SOURCE.md" > /dev/null \
  || fail "SOURCE.md contains unresolved placeholders"

license_count="$(wc -l < "$TOOL_DIR/licenses/manifest.sha256" | tr -d ' ')"
[[ "$license_count" -ge 200 ]] \
  || fail "license bundle is unexpectedly small: $license_count files"
(
  cd "$TOOL_DIR/licenses"
  sha256sum -c manifest.sha256 > /dev/null
) || fail "license manifest verification failed"

[[ -e "$TOOL_DIR/files/lib/x86_64-linux-gnu/libespeak-ng.so.1.52.0.1" ]] \
  || fail "expected eSpeak NG artifact is missing"
[[ -e "$TOOL_DIR/files/lib/x86_64-linux-gnu/libonnxruntime.so.1.14.1" ]] \
  || fail "expected ONNX Runtime artifact is missing"
[[ -e "$TOOL_DIR/files/lib/x86_64-linux-gnu/libopenxr_loader.so.1.1.36" ]] \
  || fail "expected OpenXR Loader artifact is missing"
[[ -e "$TOOL_DIR/files/share/xalia/xalia.exe" ]] \
  || fail "expected Xalia artifact is missing"

python3 - "$TOOL_DIR/proton" <<'PY'
from pathlib import Path
import sys

source = Path(sys.argv[1])
compile(source.read_text(), str(source), "exec")
PY

python3 - "$TOOL_DIR/files/share/default_pfx/system.reg" <<'PY'
from pathlib import Path
import re
import sys

registry = Path(sys.argv[1])
header = re.compile(r"^\[([^]]+)\]")
blocks = {}
current = None

def normalized(value: str) -> str:
    return value.replace("\\\\", "\\").lower()

for line in registry.read_text(errors="ignore").splitlines():
    if line.startswith("["):
        if current:
            match = header.match(current[0])
            if match:
                blocks[normalized(match.group(1))] = current
        current = [line]
    elif current is not None:
        current.append(line)

if current:
    match = header.match(current[0])
    if match:
        blocks[normalized(match.group(1))] = current

def require_block(key: str, text: str) -> None:
    block = blocks.get(normalized(key))
    if block is None or text.lower() not in "\n".join(block).lower():
        raise SystemExit(f"missing registry routing: {key} -> {text}")

for prefix in ("", "Wow6432Node\\"):
    require_block(
        f"Software\\{prefix}Microsoft\\Windows Media Foundation\\SchemeHandlers\\rtsp:",
        "GStreamer Scheme Handler",
    )
    require_block(
        f"Software\\{prefix}Microsoft\\Windows Media Foundation\\SchemeHandlers\\rtsps:",
        "GStreamer Scheme Handler",
    )

print("RTSP media registry routing verified")
PY

grep -Fq 'self.check_environment("PROTON_USE_WAYLAND", "wayland")' "$TOOL_DIR/proton" \
  || fail "native Wayland flag handling is missing"
grep -Fq 'self.env.get("PROTON_XR_MODE", "auto")' "$TOOL_DIR/proton" \
  || fail "XR mode selector is missing"
grep -Fq 'self.dlloverrides["wineopenxr"] = "d"' "$TOOL_DIR/proton" \
  || fail "scoped XRizer override is missing"
grep -Fq 'sys.dont_write_bytecode = True' "$TOOL_DIR/proton" \
  || fail "bundled-helper bytecode-cache suppression is missing"
grep -Fq '"Proton-RTSP-11.1-Wayland-GE"' "$TOOL_DIR/compatibilitytool.vdf" \
  || fail "compatibility tool internal name is incorrect"
grep -Fq '"display_name" "Proton RTSP 11.1 Wayland (GE patches)"' "$TOOL_DIR/compatibilitytool.vdf" \
  || fail "compatibility tool display name is incorrect"
grep -Fq 'en_US.UTF-8/Compose' "$TOOL_DIR/files/share/X11/locale/compose.dir" \
  || fail "Compose locale mapping is missing"

if rg -a -l -P -S \
    -e '/home/(?!runner/)' \
    -e '/Users/(?!runner/)' \
    -e '[A-Za-z]:\\Users\\(?!runner\\)' \
    "$TOOL_DIR" > /dev/null; then
  rg -a -l -P -S \
    -e '/home/(?!runner/)' \
    -e '/Users/(?!runner/)' \
    -e '[A-Za-z]:\\Users\\(?!runner\\)' \
    "$TOOL_DIR" >&2
  fail "release contains a personal home-directory path"
fi

absolute_links="$(find "$TOOL_DIR" -type l -lname '/*' -print)"
[[ -z "$absolute_links" ]] || {
  printf '%s\n' "$absolute_links" >&2
  fail "release contains absolute symbolic links"
}

printf 'Verified release artifacts and privacy path scan: %s\n' "$TOOL_DIR"
