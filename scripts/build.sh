#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_ROOT="${WORK_ROOT:-/tmp/proton-rtsp-wayland-ge-work}"
SOURCES_DIR="${SOURCES_DIR:-$WORK_ROOT/sources}"
RTSP_TREE="$SOURCES_DIR/proton-ge-rtsp"
BUILD_NAME="Proton-RTSP-11.1-Wayland-GE"
DISPLAY_NAME="Proton RTSP 11.1 Wayland (GE patches)"
JOBS="${JOBS:-2}"
DIST_DIR="${DIST_DIR:-$ROOT_DIR/dist}"
TOOL_DIR="$RTSP_TREE/build/$BUILD_NAME"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

[[ -f "$WORK_ROOT/.prepared" ]] || fail "run scripts/apply-patches.sh first"
[[ -x "$RTSP_TREE/configure.sh" ]] || fail "prepared RTSP source is missing"

if [[ ! -f "$RTSP_TREE/build/build-$BUILD_NAME/Makefile" ]]; then
  (
    cd "$RTSP_TREE"
    ./configure.sh --build-name="$BUILD_NAME" --enable-ccache
  )
fi

(
  cd "$RTSP_TREE"
  MAKEFLAGS="-j$JOBS" NINJA_JOBS="$JOBS" \
    make "build_name=$BUILD_NAME" redist
)

find "$TOOL_DIR" -type d -name __pycache__ -prune -exec rm -rf {} +

python3 - "$TOOL_DIR/compatibilitytool.vdf" "$DISPLAY_NAME" <<'PY'
from pathlib import Path
import re
import sys

manifest = Path(sys.argv[1])
display_name = sys.argv[2]
text, count = re.subn(
    r'(?m)^(\s*)"display_name"\s+"[^"]+"',
    rf'\1"display_name" "{display_name}"',
    manifest.read_text(),
    count=1,
)
if count != 1:
    raise SystemExit("failed to update compatibility tool display name")
manifest.write_text(text)
PY

SOURCE_TREE="$RTSP_TREE" \
PROTON_BUILD_DIR="$RTSP_TREE/build/build-$BUILD_NAME" \
XALIA_SOURCE_DIR="$SOURCES_DIR/xalia" \
BUILD_NAME="$BUILD_NAME" \
  "$ROOT_DIR/scripts/collect-licenses.sh" "$TOOL_DIR"

"$ROOT_DIR/scripts/verify.sh" "$TOOL_DIR"

mkdir -p "$DIST_DIR"
archive="$DIST_DIR/$BUILD_NAME.tar.gz"
checksum="$archive.sha512sum"
[[ ! -e "$archive" ]] || fail "archive already exists: $archive"

SOURCE_TREE="$RTSP_TREE" \
PROTON_BUILD_DIR="$RTSP_TREE/build/build-$BUILD_NAME" \
XALIA_SOURCE_DIR="$SOURCES_DIR/xalia" \
BUILD_NAME="$BUILD_NAME" \
DIST_DIR="$DIST_DIR" \
CARGO_REGISTRY_SRC="${CARGO_REGISTRY_SRC:-}" \
CARGO_GIT_CHECKOUTS="${CARGO_GIT_CHECKOUTS:-}" \
  "$ROOT_DIR/scripts/package-corresponding-source.sh"

tar --sort=name --owner=0 --group=0 --numeric-owner \
  -C "$(dirname "$TOOL_DIR")" -czf "$archive" "$(basename "$TOOL_DIR")"
(
  cd "$DIST_DIR"
  sha512sum "$(basename "$archive")" > "$(basename "$checksum")"
)

printf 'Release directory: %s\n' "$TOOL_DIR"
printf 'Archive: %s\n' "$archive"
printf 'Checksum: %s\n' "$checksum"
