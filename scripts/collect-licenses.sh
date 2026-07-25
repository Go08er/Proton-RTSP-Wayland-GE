#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOL_DIR="${1:-}"
SOURCE_TREE="${SOURCE_TREE:-}"
PROJECT_DIR="${PROJECT_DIR:-$ROOT_DIR}"
BUILD_NAME="${BUILD_NAME:-Proton-RTSP-Wayland-GE-Beta1}"
XALIA_SOURCE_DIR="${XALIA_SOURCE_DIR:-}"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

[[ -n "$TOOL_DIR" ]] || fail "usage: SOURCE_TREE=/path/to/source $0 /path/to/tool"
[[ -d "$TOOL_DIR" ]] || fail "tool directory does not exist: $TOOL_DIR"
[[ -n "$SOURCE_TREE" ]] || fail "SOURCE_TREE is required"
[[ -d "$SOURCE_TREE" ]] || fail "source tree does not exist: $SOURCE_TREE"
[[ -f "$SOURCE_TREE/wine/COPYING.LIB" ]] || fail "Wine license is missing from source tree"
[[ -f "$PROJECT_DIR/LICENSE" ]] || fail "project LICENSE is missing"
[[ -f "$PROJECT_DIR/COPYING.LIB.wine" ]] || fail "project Wine license copy is missing"

TOOL_DIR="$(cd "$TOOL_DIR" && pwd)"
SOURCE_TREE="$(cd "$SOURCE_TREE" && pwd)"
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
LICENSE_DIR="$TOOL_DIR/licenses"

[[ "$LICENSE_DIR" == "$TOOL_DIR/licenses" ]] || fail "unsafe license output path"
rm -rf -- "$LICENSE_DIR"
mkdir -p "$LICENSE_DIR/upstream"

for name in \
  LICENSE \
  LICENSE.proton \
  LICENSE.upstream-proton \
  LICENSE.wine \
  COPYING.LIB.wine \
  NOTICE.md \
  SOURCE.md; do
  install -m 0644 "$PROJECT_DIR/$name" "$TOOL_DIR/$name"
done

cp -a "$PROJECT_DIR/licenses/." "$LICENSE_DIR/"
mkdir -p "$LICENSE_DIR/upstream"

copy_notices() {
  local source_root="$1"
  local namespace="$2"
  local file relative destination

  [[ -d "$source_root" ]] || fail "notice source does not exist: $source_root"

  while IFS= read -r -d '' file; do
    relative="${file#./}"
    destination="$LICENSE_DIR/upstream${namespace:+/$namespace}/$relative"
    install -D -m 0644 "$source_root/$relative" "$destination"
  done < <(
    cd "$source_root"
    find . \
      \( -path './.git' -o -path '*/.git' -o -path './build' -o -path '*/__pycache__' \) -prune -o \
      -type f \( \
        -iname 'license' -o -iname 'license.*' -o -iname 'license-*' -o \
        -iname 'copying' -o -iname 'copying.*' -o \
        -iname 'notice' -o -iname 'notice.*' -o \
        -iname 'copyright' -o -iname 'copyright.*' -o \
        -iname 'patents' -o -iname 'patents.*' -o \
        -iname 'thirdpartynotices*' -o -iname 'privacy.md' -o \
        -name 'dist.LICENSE' \
      \) -print0
  )
}

copy_notices "$SOURCE_TREE" ""

PROTON_BUILD_DIR="${PROTON_BUILD_DIR:-$SOURCE_TREE/build/build-$BUILD_NAME}"
PIPER_EXTERNAL="$PROTON_BUILD_DIR/obj-piper-x86_64/p/src/piper_phonemize_external"
ESPEAK_EXTERNAL="$PROTON_BUILD_DIR/obj-piper-x86_64/p/src/piper_phonemize_external-build/e/src/espeak_ng_external"
XRANDR_EXTERNAL="$PROTON_BUILD_DIR/src-xrandr"

copy_notices "$PIPER_EXTERNAL" "external/piper-phonemize"
copy_notices "$ESPEAK_EXTERNAL" "external/espeak-ng"
copy_notices "$XRANDR_EXTERNAL" "external/xrandr"

if [[ -n "$XALIA_SOURCE_DIR" ]]; then
  copy_notices "$XALIA_SOURCE_DIR" "external/xalia"
fi

(
  cd "$LICENSE_DIR"
  find . -type f ! -name manifest.sha256 -print0 \
    | LC_ALL=C sort -z \
    | xargs -0 sha256sum > manifest.sha256
)

license_count="$(wc -l < "$LICENSE_DIR/manifest.sha256" | tr -d ' ')"
[[ "$license_count" -ge 200 ]] \
  || fail "license bundle is unexpectedly small: $license_count files"

printf 'Collected %s license and notice files for %s\n' "$license_count" "$BUILD_NAME"
