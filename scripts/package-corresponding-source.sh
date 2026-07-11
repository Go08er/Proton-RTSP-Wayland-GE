#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_ROOT="${WORK_ROOT:-/tmp/proton-rtsp-wayland-ge-work}"
SOURCES_DIR="${SOURCES_DIR:-$WORK_ROOT/sources}"
SOURCE_TREE="${SOURCE_TREE:-$SOURCES_DIR/proton-ge-rtsp}"
XALIA_SOURCE_DIR="${XALIA_SOURCE_DIR:-$SOURCES_DIR/xalia}"
BUILD_NAME="${BUILD_NAME:-Proton-RTSP-11.1-Wayland-GE}"
PROTON_BUILD_DIR="${PROTON_BUILD_DIR:-$SOURCE_TREE/build/build-$BUILD_NAME}"
DIST_DIR="${DIST_DIR:-$ROOT_DIR/dist}"
SOURCE_NAME="$BUILD_NAME-source"
PACKAGE_PARENT="${PACKAGE_PARENT:-$WORK_ROOT/corresponding-source}"
PACKAGE_DIR="$PACKAGE_PARENT/$SOURCE_NAME"

CARGO_REGISTRY_SRC="${CARGO_REGISTRY_SRC:-}"
CARGO_GIT_CHECKOUTS="${CARGO_GIT_CHECKOUTS:-}"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

require_file() {
  [[ -s "$1" ]] || fail "missing or empty source input: $1"
}

require_sha256() {
  local expected="$1"
  local path="$2"
  local actual

  require_file "$path"
  actual="$(sha256sum "$path")"
  actual="${actual%% *}"
  [[ "$actual" == "$expected" ]] \
    || fail "SHA-256 mismatch for $path: expected $expected, got $actual"
}

[[ -d "$SOURCE_TREE" ]] || fail "prepared source tree does not exist: $SOURCE_TREE"
[[ -d "$PROTON_BUILD_DIR" ]] || fail "build directory does not exist: $PROTON_BUILD_DIR"
[[ -d "$XALIA_SOURCE_DIR" ]] || fail "Xalia source does not exist: $XALIA_SOURCE_DIR"
[[ ! -e "$PACKAGE_DIR" ]] || fail "source package directory already exists: $PACKAGE_DIR"

PIPER_ROOT="$PROTON_BUILD_DIR/obj-piper-x86_64"
PIPER_PHONEMIZE="$PIPER_ROOT/p/src/piper_phonemize_external"
ESPEAK_NG="$PIPER_ROOT/p/src/piper_phonemize_external-build/e/src/espeak_ng_external"
FMT_SOURCE="$PIPER_ROOT/f/src/fmt_external"
SPDLOG_SOURCE="$PIPER_ROOT/s/src/spdlog_external"

require_file "$SOURCE_TREE/wine/COPYING.LIB"
require_file "$SOURCE_TREE/piper/CMakeLists.txt"
grep -Fq '5ecbb9b59abcffe03a9775ae82491c9ac5037f4d.zip' "$SOURCE_TREE/piper/CMakeLists.txt" \
  || fail "Piper source still uses a mutable piper-phonemize URL"
grep -Fq 'cd89aff6c3728776ffbf382bd6574876cc67d13402140fc5e3ec8c2bc813335f' "$SOURCE_TREE/piper/CMakeLists.txt" \
  || fail "Piper immutable source hash is missing"

[[ -d "$PIPER_PHONEMIZE" ]] || fail "piper-phonemize source is missing"
[[ -d "$ESPEAK_NG" ]] || fail "eSpeak NG source is missing"
[[ -d "$FMT_SOURCE" ]] || fail "fmt source is missing"
[[ -d "$SPDLOG_SOURCE" ]] || fail "spdlog source is missing"

if [[ -d "$XALIA_SOURCE_DIR/.git" ]]; then
  xalia_head="$(git -C "$XALIA_SOURCE_DIR" rev-parse HEAD)"
  [[ "$xalia_head" == "6d946216c29052c29c660ad4cac950a6bd08a2b4" ]] \
    || fail "Xalia source is at $xalia_head"
  sdl_head="$(git -C "$XALIA_SOURCE_DIR/xalia/external/SDL3-CS" rev-parse HEAD)"
  [[ "$sdl_head" == "e26a111c1b90301e37475a4dfb6f5ce47447d677" ]] \
    || fail "Xalia SDL3-CS source is at $sdl_head"
fi

mkdir -p "$PACKAGE_DIR/source" "$PACKAGE_DIR/distribution" "$PACKAGE_DIR/external"

rsync -a \
  --exclude='.git' \
  --exclude='/build/' \
  --exclude='__pycache__' \
  "$SOURCE_TREE/" "$PACKAGE_DIR/source/"

rsync -a \
  --exclude='.git' \
  --exclude='/build/' \
  --exclude='/dist/' \
  --exclude='__pycache__' \
  "$ROOT_DIR/" "$PACKAGE_DIR/distribution/"

rsync -a --exclude='.git' "$PIPER_PHONEMIZE/" "$PACKAGE_DIR/external/piper-phonemize/"
rsync -a --exclude='.git' "$ESPEAK_NG/" "$PACKAGE_DIR/external/espeak-ng/"
rsync -a --exclude='.git' "$FMT_SOURCE/" "$PACKAGE_DIR/external/fmt/"
rsync -a --exclude='.git' "$SPDLOG_SOURCE/" "$PACKAGE_DIR/external/spdlog/"
rsync -a --exclude='.git' "$XALIA_SOURCE_DIR/" "$PACKAGE_DIR/external/xalia/"

mkdir -p "$PACKAGE_DIR/external/download-archives"
piper_archive="$PIPER_ROOT/p/src/5ecbb9b59abcffe03a9775ae82491c9ac5037f4d.zip"
if [[ ! -s "$piper_archive" ]]; then
  piper_archive="$PIPER_ROOT/p/src/pic.zip"
fi

piper_archives=("$piper_archive")
original_piper_archive="$PIPER_ROOT/p/src/pic.zip"
if [[ "$(basename "$piper_archive")" == "5ecbb9b59abcffe03a9775ae82491c9ac5037f4d.zip" ]]; then
  require_sha256 \
    "cd89aff6c3728776ffbf382bd6574876cc67d13402140fc5e3ec8c2bc813335f" \
    "$piper_archive"
else
  require_sha256 \
    "728800cd310c64e6b6877866161b32ff0dc2d9c52ebdc54281fa21e448d2adef" \
    "$piper_archive"
fi

if [[ -s "$original_piper_archive" && "$original_piper_archive" != "$piper_archive" ]]; then
  require_sha256 \
    "728800cd310c64e6b6877866161b32ff0dc2d9c52ebdc54281fa21e448d2adef" \
    "$original_piper_archive"
  piper_archives+=("$original_piper_archive")
fi

for archive in \
  "${piper_archives[@]}" \
  "$PIPER_ROOT/p/src/piper_phonemize_external-build/e/src/0f65aa301e0d6bae5e172cc74197d32a6182200f.zip" \
  "$PIPER_ROOT/p/src/piper_phonemize_external-build/download/onnxruntime-linux-x64-1.14.1.tgz" \
  "$PIPER_ROOT/f/src/10.0.0.zip" \
  "$PIPER_ROOT/s/src/v1.12.0.zip"; do
  require_file "$archive"
  cp -a "$archive" "$PACKAGE_DIR/external/download-archives/"
done

if [[ -n "$CARGO_REGISTRY_SRC" && -d "$CARGO_REGISTRY_SRC" ]]; then
  rsync -a --exclude='.git' "$CARGO_REGISTRY_SRC/" "$PACKAGE_DIR/external/cargo-registry-src/"
fi

if [[ -n "$CARGO_GIT_CHECKOUTS" && -d "$CARGO_GIT_CHECKOUTS" ]]; then
  rsync -a --exclude='.git' "$CARGO_GIT_CHECKOUTS/" "$PACKAGE_DIR/external/cargo-git-checkouts/"
fi

install -m 0644 "$ROOT_DIR/SOURCE.md" "$PACKAGE_DIR/SOURCE.md"
install -m 0644 "$ROOT_DIR/NOTICE.md" "$PACKAGE_DIR/NOTICE.md"

(
  cd "$PACKAGE_DIR"
  find . -type f -printf '%P\n' | LC_ALL=C sort > SOURCE-CONTENTS.txt
)

if [[ -n "${HOME:-}" ]] && rg -a -l -F "$HOME" "$PACKAGE_DIR" > /dev/null; then
  rg -a -l -F "$HOME" "$PACKAGE_DIR" >&2
  fail "corresponding source contains the builder's home path"
fi

mkdir -p "$DIST_DIR"
archive="$DIST_DIR/$SOURCE_NAME.tar.gz"
checksum="$archive.sha512sum"
[[ ! -e "$archive" ]] || fail "source archive already exists: $archive"
[[ ! -e "$checksum" ]] || fail "source checksum already exists: $checksum"

tar --sort=name --owner=0 --group=0 --numeric-owner \
  -C "$PACKAGE_PARENT" -czf "$archive" "$SOURCE_NAME"
(
  cd "$DIST_DIR"
  sha512sum "$(basename "$archive")" > "$(basename "$checksum")"
)

printf 'Corresponding source directory: %s\n' "$PACKAGE_DIR"
printf 'Corresponding source archive: %s\n' "$archive"
printf 'Corresponding source checksum: %s\n' "$checksum"
