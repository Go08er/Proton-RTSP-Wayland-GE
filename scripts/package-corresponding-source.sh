#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/config/upstream-pins.sh"
WORK_ROOT="${WORK_ROOT:-/tmp/proton-rtsp-wayland-ge-beta1-11-3}"
SOURCES_DIR="${SOURCES_DIR:-$WORK_ROOT/sources}"
SOURCE_TREE="${SOURCE_TREE:-$SOURCES_DIR/proton-ge-rtsp}"
XALIA_SOURCE_DIR="${XALIA_SOURCE_DIR:-$SOURCES_DIR/xalia}"
BUILD_NAME="${BUILD_NAME:-Proton-RTSP-Wayland-GE-Beta1}"
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
  [[ -f "$1" && ! -L "$1" && -s "$1" ]] \
    || fail "missing, empty, or unsafe source input: $1"
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

require_clean_git() {
  local tree="$1"
  local label="$2"
  local status

  status="$(git -C "$tree" status --porcelain=v1 --untracked-files=all)" \
    || fail "cannot inspect $label"
  if [[ -n "$status" ]]; then
    printf '%s\n' "$status" >&2
    fail "$label must be clean; commit intended files and remove unexpected untracked files"
  fi
}

copy_tracked_project() {
  local destination="$1"

  mkdir -p "$destination"
  if ! git -C "$ROOT_DIR" ls-files --cached -z \
      | rsync -a --from0 --files-from=- "$ROOT_DIR/" "$destination/"; then
    fail "could not export tracked distribution files"
  fi
}

reject_rg_matches() {
  local message="$1"
  shift
  local output status

  if output="$(rg "$@" 2>&1)"; then
    printf '%s\n' "$output" >&2
    fail "$message"
  else
    status=$?
  fi
  if (( status != 1 )); then
    printf '%s\n' "$output" >&2
    fail "$message scan failed (ripgrep exit $status)"
  fi
}

[[ -d "$SOURCE_TREE" ]] || fail "prepared source tree does not exist: $SOURCE_TREE"
[[ -d "$PROTON_BUILD_DIR" ]] || fail "build directory does not exist: $PROTON_BUILD_DIR"
[[ -d "$XALIA_SOURCE_DIR" ]] || fail "Xalia source does not exist: $XALIA_SOURCE_DIR"
[[ ! -e "$PACKAGE_DIR" ]] || fail "source package directory already exists: $PACKAGE_DIR"

require_clean_git "$ROOT_DIR" "distribution repository"

PIPER_ROOT="$PROTON_BUILD_DIR/obj-piper-x86_64"
PIPER_PHONEMIZE="$PIPER_ROOT/p/src/piper_phonemize_external"
ESPEAK_NG="$PIPER_ROOT/p/src/piper_phonemize_external-build/e/src/espeak_ng_external"
FMT_SOURCE="$PIPER_ROOT/f/src/fmt_external"
SPDLOG_SOURCE="$PIPER_ROOT/s/src/spdlog_external"

require_file "$SOURCE_TREE/wine/COPYING.LIB"
require_file "$SOURCE_TREE/piper/CMakeLists.txt"
grep -Fq "$PIPER_PHONEMIZE_COMMIT.zip" "$SOURCE_TREE/piper/CMakeLists.txt" \
  || fail "Piper source still uses a mutable piper-phonemize URL"
grep -Fq "$PIPER_PHONEMIZE_ZIP_SHA256" "$SOURCE_TREE/piper/CMakeLists.txt" \
  || fail "Piper immutable source hash is missing"
grep -Fqx "XALIA_ZIP_SHA256 := $XALIA_ZIP_SHA256" "$SOURCE_TREE/Makefile.in" \
  || fail "prepared Makefile does not enforce the pinned Xalia archive hash"

[[ -d "$PIPER_PHONEMIZE" ]] || fail "piper-phonemize source is missing"
[[ -d "$ESPEAK_NG" ]] || fail "eSpeak NG source is missing"
[[ -d "$FMT_SOURCE" ]] || fail "fmt source is missing"
[[ -d "$SPDLOG_SOURCE" ]] || fail "spdlog source is missing"

[[ -e "$XALIA_SOURCE_DIR/.git" ]] || fail "Xalia source is not a Git checkout"
xalia_head="$(git -C "$XALIA_SOURCE_DIR" rev-parse HEAD)"
[[ "$xalia_head" == "$XALIA_COMMIT" ]] \
  || fail "Xalia source is at $xalia_head, expected $XALIA_COMMIT"
[[ -z "$(git -C "$XALIA_SOURCE_DIR" status --porcelain --untracked-files=all)" ]] \
  || fail "Xalia source contains local changes"
sdl_head="$(git -C "$XALIA_SOURCE_DIR/xalia/external/SDL3-CS" rev-parse HEAD)"
[[ "$sdl_head" == "$XALIA_SDL3_CS_COMMIT" ]] \
  || fail "Xalia SDL3-CS source is at $sdl_head, expected $XALIA_SDL3_CS_COMMIT"

mkdir -p "$PACKAGE_DIR/source" "$PACKAGE_DIR/distribution" "$PACKAGE_DIR/external"

rsync -a \
  --exclude='.git' \
  --exclude='/build/' \
  --exclude='__pycache__' \
  "$SOURCE_TREE/" "$PACKAGE_DIR/source/"

copy_tracked_project "$PACKAGE_DIR/distribution"

rsync -a --exclude='.git' "$PIPER_PHONEMIZE/" "$PACKAGE_DIR/external/piper-phonemize/"
rsync -a --exclude='.git' "$ESPEAK_NG/" "$PACKAGE_DIR/external/espeak-ng/"
rsync -a --exclude='.git' "$FMT_SOURCE/" "$PACKAGE_DIR/external/fmt/"
rsync -a --exclude='.git' "$SPDLOG_SOURCE/" "$PACKAGE_DIR/external/spdlog/"
rsync -a --exclude='.git' "$XALIA_SOURCE_DIR/" "$PACKAGE_DIR/external/xalia/"

mkdir -p "$PACKAGE_DIR/external/download-archives"
piper_archive="$PIPER_ROOT/p/src/$PIPER_PHONEMIZE_COMMIT.zip"
require_sha256 \
  "$PIPER_PHONEMIZE_ZIP_SHA256" \
  "$piper_archive"
xalia_archive="$SOURCE_TREE/contrib/$XALIA_ZIP_NAME"
require_sha256 "$XALIA_ZIP_SHA256" "$xalia_archive"

for archive in \
  "$piper_archive" \
  "$xalia_archive" \
  "$PIPER_ROOT/p/src/piper_phonemize_external-build/e/src/0f65aa301e0d6bae5e172cc74197d32a6182200f.zip" \
  "$PIPER_ROOT/p/src/piper_phonemize_external-build/download/onnxruntime-linux-x64-1.14.1.tgz" \
  "$PIPER_ROOT/f/src/10.0.0.zip" \
  "$PIPER_ROOT/s/src/v1.12.0.zip"; do
  require_file "$archive"
  cp -a "$archive" "$PACKAGE_DIR/external/download-archives/"
done

if [[ -n "$CARGO_REGISTRY_SRC" ]]; then
  [[ -d "$CARGO_REGISTRY_SRC" && ! -L "$CARGO_REGISTRY_SRC" ]] \
    || fail "CARGO_REGISTRY_SRC is not a real directory: $CARGO_REGISTRY_SRC"
  rsync -a --exclude='.git' \
    "$CARGO_REGISTRY_SRC/" "$PACKAGE_DIR/external/cargo-registry-src/"
fi

if [[ -n "$CARGO_GIT_CHECKOUTS" ]]; then
  [[ -d "$CARGO_GIT_CHECKOUTS" && ! -L "$CARGO_GIT_CHECKOUTS" ]] \
    || fail "CARGO_GIT_CHECKOUTS is not a real directory: $CARGO_GIT_CHECKOUTS"
  rsync -a --exclude='.git' \
    "$CARGO_GIT_CHECKOUTS/" "$PACKAGE_DIR/external/cargo-git-checkouts/"
fi

install -m 0644 "$ROOT_DIR/SOURCE.md" "$PACKAGE_DIR/SOURCE.md"
install -m 0644 "$ROOT_DIR/NOTICE.md" "$PACKAGE_DIR/NOTICE.md"

(
  cd "$PACKAGE_DIR"
  find . -type f -printf '%P\n' | LC_ALL=C sort > SOURCE-CONTENTS.txt
)

[[ -n "${HOME:-}" && "$HOME" == /* && "$HOME" != "/" ]] \
  || fail "HOME must be a non-root absolute path for privacy validation"
reject_rg_matches \
  "corresponding source contains the builder's home path" \
  -a -l -i -F --hidden --no-ignore -- "$HOME" "$PACKAGE_DIR"

# Upstream source contains intentional documentation and tests with example
# home paths.  Scan the distribution-authored portion generically while the
# exact builder-home scan above still covers the complete source package.  The
# one exception is LLVM-MinGW's immutable public CI source prefix.
reject_rg_matches \
    "corresponding source contains a personal home-directory path" \
    -a -l -i -P --hidden --no-ignore \
    -e '/home/(?!runner/work/llvm-mingw/)[[:alnum:]_.-]+(?:/|$)' \
    -e '/users/[[:alnum:]_.-]+(?:/|$)' \
    -e '/root(?:/|$)' \
    -e '[a-z]:\\+users\\+[[:alnum:]_.-]+(?:\\+|$)' \
    -- "$PACKAGE_DIR/distribution" "$PACKAGE_DIR/SOURCE.md" "$PACKAGE_DIR/NOTICE.md"

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
