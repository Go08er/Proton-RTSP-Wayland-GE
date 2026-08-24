#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOL_DIR="${1:-}"
BUILD_NAME="${BUILD_NAME:-Proton-RTSP-Wayland-GE-Beta2}"
DISPLAY_NAME="${DISPLAY_NAME:-Proton RTSP Wayland GE Beta 2}"
SOURCE_ARCHIVE_NAME="${SOURCE_ARCHIVE_NAME:-${BUILD_NAME}-source.tar.gz}"
GE_SOURCE_LABEL="${GE_SOURCE_LABEL:-GE-Proton11-5}"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

require_file() {
  [[ -s "$TOOL_DIR/$1" ]] || fail "missing or empty artifact: $1"
}

require_executable() {
  [[ -f "$TOOL_DIR/$1" && -x "$TOOL_DIR/$1" ]] \
    || fail "missing or non-executable artifact: $1"
}

[[ -n "$TOOL_DIR" ]] || fail "usage: $0 /path/to/compatibility-tool"
[[ -d "$TOOL_DIR" ]] || fail "tool directory does not exist: $TOOL_DIR"
[[ -n "$BUILD_NAME" ]] || fail "BUILD_NAME must not be empty"
[[ -n "$DISPLAY_NAME" ]] || fail "DISPLAY_NAME must not be empty"
[[ -n "$SOURCE_ARCHIVE_NAME" ]] || fail "SOURCE_ARCHIVE_NAME must not be empty"
command -v rg > /dev/null || fail "ripgrep (rg) is required"

require_file proton
require_file compatibilitytool.vdf
require_file toolmanifest.vdf
require_file version
require_file files/bin/wine
require_file files/bin/wineserver
require_file files/bin/xrandr
require_file files/lib/wine/x86_64-unix/winewayland.so
require_file files/lib/wine/i386-unix/winewayland.so
require_file files/lib/wine/x86_64-windows/winewayland.drv
require_file files/lib/wine/i386-windows/winewayland.drv
require_file files/lib/wine/x86_64-unix/winegstreamer.so
require_file files/lib/wine/i386-unix/winegstreamer.so
require_file files/lib/wine/x86_64-windows/winegstreamer.dll
require_file files/lib/wine/i386-windows/winegstreamer.dll
require_file files/lib/wine/x86_64-unix/wineopenxr.so
require_file files/lib/wine/x86_64-windows/wineopenxr.dll
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

for arch in x86_64-linux-gnu i386-linux-gnu; do
  require_file "files/lib/$arch/libgstreamer-1.0.so"
  require_file "files/lib/$arch/libgstrtsp-1.0.so"
  require_file "files/lib/$arch/libgstsdp-1.0.so"
  require_file "files/lib/$arch/libgstrtp-1.0.so"
  require_file "files/lib/$arch/gstreamer-1.0/libgstcoreelements.so"
  require_file "files/lib/$arch/gstreamer-1.0/libgstlibav.so"
  require_file "files/lib/$arch/gstreamer-1.0/libgstplayback.so"
  require_file "files/lib/$arch/gstreamer-1.0/libgstrtp.so"
  require_file "files/lib/$arch/gstreamer-1.0/libgstrtpmanager.so"
  require_file "files/lib/$arch/gstreamer-1.0/libgstrtsp.so"
  require_file "files/lib/$arch/gstreamer-1.0/libgstsoup.so"
done

require_executable proton
require_executable files/bin/wine
require_executable files/bin/wineserver
require_executable files/bin/xrandr

read -r version_epoch version_identity version_extra < "$TOOL_DIR/version"
version_prefix="${BUILD_NAME}+proton-rtsp-"
version_suffix="+${GE_SOURCE_LABEL}"
[[ "$version_epoch" =~ ^[0-9]+$ && -z "${version_extra:-}" \
    && "$version_identity" == "$version_prefix"*"$version_suffix" ]] \
  || fail "version does not identify this build, the RTSP base, and the GE source"
grep -Fq '"version" "2"' "$TOOL_DIR/toolmanifest.vdf" \
  || fail "tool manifest version is incorrect"
grep -Fq '"commandline" "/proton %verb%"' "$TOOL_DIR/toolmanifest.vdf" \
  || fail "tool manifest command line is incorrect"

grep -Fq 'Proton-RTSP-Wayland-GE contributors' "$TOOL_DIR/LICENSE" \
  || fail "project BSD-3-Clause license is not installed"
grep -Fq 'Valve Corporation' "$TOOL_DIR/LICENSE.proton" \
  || fail "upstream Proton license is not installed"
grep -Fiq 'GNU LESSER GENERAL PUBLIC LICENSE' "$TOOL_DIR/COPYING.LIB.wine" \
  || fail "Wine LGPL text is not installed"
grep -Fq "$SOURCE_ARCHIVE_NAME" "$TOOL_DIR/SOURCE.md" \
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
from collections import defaultdict
from pathlib import Path
import re
import sys

registry = Path(sys.argv[1])
header = re.compile(r"^\[([^]]+)\]")
blocks = defaultdict(list)
current = None

def normalized(value: str) -> str:
    return value.replace("\\\\", "\\").lower()

for line in registry.read_text(errors="ignore").splitlines():
    if line.startswith("["):
        if current:
            match = header.match(current[0])
            if match:
                blocks[normalized(match.group(1))].append(current)
        current = [line]
    elif current is not None:
        current.append(line)

if current:
    match = header.match(current[0])
    if match:
        blocks[normalized(match.group(1))].append(current)

gstreamer_schemes = (
    "http:",
    "https:",
    "rtsp-sdp:",
    "rtsp:",
    "rtsph:",
    "rtsps:",
    "rtspsh:",
    "rtspst:",
    "rtspsu:",
    "rtspt:",
    "rtspu:",
)
expected = {"file:": "File Scheme Handler"}
expected.update({scheme: "GStreamer Scheme Handler" for scheme in gstreamer_schemes})

for prefix in ("", "Wow6432Node\\"):
    base = normalized(
        f"Software\\{prefix}Microsoft\\Windows Media Foundation\\SchemeHandlers\\"
    )
    actual = {
        key[len(base):]: entries
        for key, entries in blocks.items()
        if key.startswith(base)
    }
    missing = sorted(set(expected) - set(actual))
    unexpected = sorted(set(actual) - set(expected))
    if missing or unexpected:
        view = "Wow6432" if prefix else "native"
        raise SystemExit(
            f"{view} SchemeHandlers mismatch: missing={missing}, unexpected={unexpected}"
        )
    for scheme, handler in expected.items():
        entries = actual[scheme]
        if len(entries) != 1:
            raise SystemExit(
                f"duplicate registry routing in {prefix or 'native'} view: {scheme}"
            )
        if handler.lower() not in "\n".join(entries[0]).lower():
            raise SystemExit(
                f"incorrect registry routing in {prefix or 'native'} view: "
                f"{scheme} -> {handler}"
            )

print("Verified 12 media schemes per registry view (11 GStreamer plus file)")
PY

grep -Fq 'self.check_environment("PROTON_USE_WAYLAND", "wayland")' "$TOOL_DIR/proton" \
  || fail "native Wayland flag handling is missing"
! rg -n 'PROTON_XR_MODE|self\.xr_mode' "$TOOL_DIR/proton" > /dev/null \
  || fail "retired project-specific XR mode handling remains in the launcher"
! grep -Fq 'self.dlloverrides["wineopenxr"] = "d"' "$TOOL_DIR/proton" \
  || fail "project-injected WineOpenXR disable remains in the launcher"
grep -Fqx 'CURRENT_PREFIX_VERSION="11.0-103"' "$TOOL_DIR/proton" \
  || fail "expected 11.0-103 prefix identity is missing"
grep -Fq 'self.env["PROTON_NO_STEAMINPUT"] = "1"' "$TOOL_DIR/proton" \
  || fail "$GE_SOURCE_LABEL WineWayland Steam Input policy is missing"
grep -Fq 'self.force_steam_input_appid = True' "$TOOL_DIR/proton" \
  || fail "$GE_SOURCE_LABEL Steam Input AppID policy is not enabled for WineWayland"
grep -Fq '[steam_bin, "steam://forceinputappid/" + str(appid)]' "$TOOL_DIR/proton" \
  || fail "$GE_SOURCE_LABEL Steam Input AppID selection is missing"
grep -Fq 'steam_bin = shutil.which("steam")' "$TOOL_DIR/proton" \
  || fail "Steam Input AppID selection does not resolve the host Steam client"
grep -Fqx '        env = dict(os.environ)' "$TOOL_DIR/proton" \
  || fail "Steam Input AppID selection does not start from the host environment"
grep -Fq 'for name in ("SteamAppId", "SteamGameId", "STEAM_COMPAT_APP_ID"):' "$TOOL_DIR/proton" \
  || fail "Steam Input AppID selection does not sanitize game identity variables"
grep -Fq 'env.pop(name, None)' "$TOOL_DIR/proton" \
  || fail "Steam Input AppID selection does not remove game identity variables"
grep -Fq 'env=env,' "$TOOL_DIR/proton" \
  || fail "Steam Input AppID selection does not pass the sanitized environment"
grep -Fq 'self.set_steam_input_appid(0)' "$TOOL_DIR/proton" \
  || fail "$GE_SOURCE_LABEL Steam Input AppID reset is missing"
grep -Fq 'sys.dont_write_bytecode = True' "$TOOL_DIR/proton" \
  || fail "bundled-helper bytecode-cache suppression is missing"
grep -Fq "\"$BUILD_NAME\"" "$TOOL_DIR/compatibilitytool.vdf" \
  || fail "compatibility tool internal name is incorrect"
grep -Fq "\"display_name\" \"$DISPLAY_NAME\"" "$TOOL_DIR/compatibilitytool.vdf" \
  || fail "compatibility tool display name is incorrect"
grep -Fq 'en_US.UTF-8/Compose' "$TOOL_DIR/files/share/X11/locale/compose.dir" \
  || fail "Compose locale mapping is missing"

python3 - "$TOOL_DIR" "${HOME:-}" <<'PY'
from pathlib import Path
import mmap
import os
import re
import stat
import sys

root = Path(sys.argv[1]).resolve(strict=True)
builder_home = os.fsencode(sys.argv[2]) if sys.argv[2] else b""
regular_files = []
filesystem_violations = []
walk_errors = []

def relative(path: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return str(path)

def record_filesystem(message: str) -> None:
    filesystem_violations.append(message)

stack = [root]
while stack:
    directory = stack.pop()
    try:
        entries = list(os.scandir(directory))
    except OSError as error:
        walk_errors.append(f"{relative(directory)}: {error}")
        continue
    for entry in entries:
        path = Path(entry.path)
        try:
            mode = entry.stat(follow_symlinks=False).st_mode
        except OSError as error:
            walk_errors.append(f"{relative(path)}: {error}")
            continue

        if stat.S_ISDIR(mode):
            if mode & (stat.S_ISUID | stat.S_ISGID):
                record_filesystem(f"setuid/setgid directory: {relative(path)}")
            if mode & stat.S_IWOTH:
                record_filesystem(f"world-writable directory: {relative(path)}")
            stack.append(path)
        elif stat.S_ISREG(mode):
            if mode & (stat.S_ISUID | stat.S_ISGID):
                record_filesystem(f"setuid/setgid file: {relative(path)}")
            if mode & stat.S_IWOTH:
                record_filesystem(f"world-writable file: {relative(path)}")
            regular_files.append(path)
        elif stat.S_ISLNK(mode):
            try:
                target = os.readlink(path)
            except OSError as error:
                walk_errors.append(f"{relative(path)}: {error}")
                continue
            if os.path.isabs(target):
                record_filesystem(f"absolute symlink: {relative(path)} -> {target}")
                continue
            try:
                resolved = path.resolve(strict=True)
            except (OSError, RuntimeError) as error:
                record_filesystem(f"broken symlink: {relative(path)} -> {target} ({error})")
                continue
            try:
                resolved.relative_to(root)
            except ValueError:
                record_filesystem(
                    f"out-of-root symlink: {relative(path)} -> {target} ({resolved})"
                )
        else:
            record_filesystem(
                f"special file (mode {stat.filemode(mode)}): {relative(path)}"
            )

root_mode = root.stat().st_mode
if root_mode & (stat.S_ISUID | stat.S_ISGID):
    record_filesystem("setuid/setgid artifact root: .")
if root_mode & stat.S_IWOTH:
    record_filesystem("world-writable artifact root: .")

if walk_errors or filesystem_violations:
    for item in walk_errors:
        print(f"scan error: {item}", file=sys.stderr)
    for item in filesystem_violations:
        print(item, file=sys.stderr)
    raise SystemExit("FAIL: artifact filesystem safety checks failed")

# The generic scanner accepts only these immutable upstream diagnostics and
# Proton's standard Windows profiles. No file or directory is excluded.
LLVM_MINGW_PREFIX = b"/home/runner/work/llvm-mingw/"
WINDOWS_PROFILE_ALLOWLIST = {b"public", b"steamuser"}
PATH_CONTINUATION = frozenset(
    b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789._~+%/-\\"
)
PATH_END = rb"(?=$|[/\\\x00\r\n\t '\";:,)\]}])"
UNIX_PATH = re.compile(
    rb"(?:(?P<home>/home/(?P<home_user>[A-Za-z0-9_.-]+))" + PATH_END
    + rb"|(?P<users>/Users/(?P<users_user>[A-Za-z0-9_.-]+))" + PATH_END
    # Bare /root is also a common Windows command switch and document token.
    # The generic case is unambiguously a home path once it continues; an
    # exact HOME=/root occurrence is still caught by the builder-HOME scan.
    + rb"|(?P<root>/root)(?=[/\\]))"
)
WINDOWS_PATH = re.compile(
    rb"(?i)(?P<windows>[a-z]:[\\/]+users[\\/]+"
    rb"(?P<windows_user>[a-z0-9_.-]+))" + PATH_END
)
UTF16_LE_ASCII = re.compile(rb"(?:[\x09\x20-\x7e]\x00){4,}")
UTF16_BE_ASCII = re.compile(rb"(?:\x00[\x09\x20-\x7e]){4,}")
home_pattern = re.compile(re.escape(builder_home), re.IGNORECASE) if builder_home else None
home_is_runner = builder_home.rstrip(b"/").lower() == b"/home/runner"
privacy_violations = set()
scan_errors = []
allowed_llvm_occurrences = 0

def has_absolute_boundary(view, start: int) -> bool:
    if start == 0:
        return True
    prefix = bytes(view[max(0, start - 7):start]).lower()
    if prefix.endswith(b"file://"):
        return True
    return view[start - 1] not in PATH_CONTINUATION

def is_llvm_mingw(view, start: int) -> bool:
    candidate = bytes(view[start:start + len(LLVM_MINGW_PREFIX)])
    return candidate == LLVM_MINGW_PREFIX

def add_violation(rel: str, kind: str, match: bytes, encoding: str) -> None:
    rendered = match.decode("ascii", errors="backslashreplace")
    privacy_violations.add((rel, kind, rendered, encoding))

def scan_view(view, rel: str, encoding: str) -> None:
    global allowed_llvm_occurrences
    if home_pattern is not None:
        for match in home_pattern.finditer(view):
            if not has_absolute_boundary(view, match.start()):
                continue
            if home_is_runner and is_llvm_mingw(view, match.start()):
                allowed_llvm_occurrences += 1
            else:
                add_violation(rel, "exact builder HOME", match.group(0), encoding)

    for match in UNIX_PATH.finditer(view):
        if not has_absolute_boundary(view, match.start()):
            continue
        if match.group("home") and is_llvm_mingw(view, match.start()):
            allowed_llvm_occurrences += 1
            continue
        add_violation(rel, "absolute Unix home path", match.group(0), encoding)

    for match in WINDOWS_PATH.finditer(view):
        if not has_absolute_boundary(view, match.start()):
            continue
        if match.group("windows_user").lower() in WINDOWS_PROFILE_ALLOWLIST:
            continue
        add_violation(rel, "absolute Windows user profile", match.group(0), encoding)

for path in sorted(regular_files):
    rel = relative(path)
    try:
        if path.stat().st_size == 0:
            continue
        with path.open("rb") as stream, mmap.mmap(
            stream.fileno(), 0, access=mmap.ACCESS_READ
        ) as data:
            scan_view(data, rel, "bytes")
            for match in UTF16_LE_ASCII.finditer(data):
                scan_view(match.group(0)[::2], rel, "UTF-16LE")
            for match in UTF16_BE_ASCII.finditer(data):
                scan_view(match.group(0)[1::2], rel, "UTF-16BE")
    except (OSError, ValueError) as error:
        scan_errors.append(f"{rel}: {error}")

if scan_errors:
    for item in scan_errors:
        print(f"scan error: {item}", file=sys.stderr)
    raise SystemExit("FAIL: privacy scan could not read every regular file")

if privacy_violations:
    violations = sorted(privacy_violations)
    for rel, kind, match, encoding in violations[:100]:
        print(f"{rel}: {kind} ({encoding}): {match}", file=sys.stderr)
    if len(violations) > 100:
        print(f"... {len(violations) - 100} additional matches", file=sys.stderr)
    raise SystemExit("FAIL: release contains a personal home-directory path")

print(
    f"Verified filesystem safety and scanned {len(regular_files)} regular files "
    f"without ignore rules ({allowed_llvm_occurrences} allowed LLVM-MinGW paths)"
)
PY

printf 'Verified release artifacts and privacy path scan: %s\n' "$TOOL_DIR"
