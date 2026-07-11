#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_ROOT="${WORK_ROOT:-/tmp/proton-rtsp-wayland-ge-work}"
SOURCES_DIR="${SOURCES_DIR:-$WORK_ROOT/sources}"
RTSP_TREE="$SOURCES_DIR/proton-ge-rtsp"
GE_TREE="$SOURCES_DIR/proton-ge-custom"
WINE_TREE="$RTSP_TREE/wine"
PIPER_TREE="$RTSP_TREE/piper"
SERIES="$ROOT_DIR/patches/ge11-wayland-series.txt"

RTSP_COMMIT="3b4a5f407a5e0cabeef6d3757f29a23f277b429a"
GE_COMMIT="fd07a035fadfbe989aef887cb999d0ef236c50d0"
WINE_BASE="fd920bd63abb7bf8b52b0f8e40da922ab9e784a4"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

require_head() {
  local tree="$1"
  local expected="$2"
  local actual
  actual="$(git -C "$tree" rev-parse HEAD)"
  [[ "$actual" == "$expected" ]] || fail "$tree is at $actual, expected $expected"
}

fetch_dep() {
  local name="$1"
  local url="$2"
  local commit="$3"
  local path="$RTSP_TREE/$name"

  [[ ! -e "$path" ]] || fail "$path already exists"
  git -c maintenance.auto=false -c gc.auto=0 clone --filter=blob:none --no-checkout "$url" "$path"
  git -c maintenance.auto=false -c gc.auto=0 -C "$path" fetch --filter=blob:none --depth=1 origin "$commit"
  git -C "$path" checkout --detach "$commit"
}

require_head "$RTSP_TREE" "$RTSP_COMMIT"
require_head "$GE_TREE" "$GE_COMMIT"
require_head "$WINE_TREE" "$WINE_BASE"
[[ -f "$SERIES" ]] || fail "missing patch series: $SERIES"
[[ "$(wc -l < "$SERIES" | tr -d ' ')" == "101" ]] || fail "expected 101 Wine patches"

git -C "$RTSP_TREE" apply --check "$ROOT_DIR/patches/proton-rtsp-wayland.patch"
git -C "$RTSP_TREE" apply "$ROOT_DIR/patches/proton-rtsp-wayland.patch"

git -C "$PIPER_TREE" apply --check "$ROOT_DIR/patches/piper-phonemize-pin.patch"
git -C "$PIPER_TREE" apply "$ROOT_DIR/patches/piper-phonemize-pin.patch"

while IFS= read -r patch_name; do
  [[ -n "$patch_name" ]] || continue
  patch_path="$ROOT_DIR/patches/ge11-wayland/$patch_name"
  upstream_patch="$GE_TREE/patches/wine-hotfixes/wine-wayland/$patch_name"
  [[ -f "$patch_path" ]] || fail "missing GE patch: $patch_name"
  [[ -f "$upstream_patch" ]] || fail "pinned GE source is missing patch: $patch_name"
  cmp "$patch_path" "$upstream_patch" \
    || fail "bundled patch differs from pinned GE source: $patch_name"
  git -c user.name='Proton RTSP Wayland Build' \
      -c user.email='build@localhost' \
      -C "$WINE_TREE" am "$patch_path"
done < "$SERIES"

[[ "$(git -C "$WINE_TREE" rev-list --count "$WINE_BASE..HEAD")" == "101" ]] \
  || fail "Wine patch count does not match the audited series"

cp -a "$GE_TREE/locale" "$RTSP_TREE/locale"
fetch_dep libxml2 https://gitlab.gnome.org/GNOME/libxml2.git b7fa62cbe8ef0df5869e000d5b690bdedd07f33e
fetch_dep libxkbcommon https://github.com/xkbcommon/libxkbcommon.git dd642359f8d43c09968e34ca7f1eb1121b2dfd70
fetch_dep wayland-protocols https://gitlab.freedesktop.org/wayland/wayland-protocols.git 810f1adaf33521cc55fc510566efba2a1418174f

touch "$WORK_ROOT/.prepared"
printf 'RTSP source prepared at %s\n' "$RTSP_TREE"
printf 'Next: WORK_ROOT=%q %q\n' "$WORK_ROOT" "$ROOT_DIR/scripts/build.sh"
