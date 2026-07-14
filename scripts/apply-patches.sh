#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_ROOT="${WORK_ROOT:-/tmp/proton-rtsp-wayland-ge-work}"
SOURCES_DIR="${SOURCES_DIR:-$WORK_ROOT/sources}"
RTSP_TREE="${RTSP_TREE:-$SOURCES_DIR/proton-ge-rtsp}"
GE_TREE="${GE_TREE:-$SOURCES_DIR/proton-ge-custom}"
source "$ROOT_DIR/config/upstream-pins.sh"
source "$ROOT_DIR/scripts/lib/prepared-state.sh"
PATCH_BUNDLE="$ROOT_DIR/patches/$GE_WAYLAND_PATCH_DIR"
OPENXR_PATCH="$ROOT_DIR/patches/$GE_WINEOPENXR_PATCH"
OPENXR_INTEGRATION_PATCH="$ROOT_DIR/patches/$RTSP_WINEOPENXR_INTEGRATION_PATCH"
PIPER_PATCH="$ROOT_DIR/patches/piper-phonemize-pin.patch"
PREPARED_STATE="$WORK_ROOT/.prepared"

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

require_pristine() {
  local tree="$1"
  local status

  status="$(git -C "$tree" status --porcelain --untracked-files=all)"
  [[ -z "$status" ]] || fail "$tree is not pristine"
}

require_initial_rtsp() {
  local status_line

  while IFS= read -r status_line; do
    [[ -n "$status_line" ]] || continue
    case "$status_line" in
      "?? libxml2"|"?? libxml2/"|\
      "?? libxkbcommon"|"?? libxkbcommon/"|\
      "?? wayland-protocols"|"?? wayland-protocols/") ;;
      *) fail "$RTSP_TREE is not pristine: $status_line" ;;
    esac
  done < <(git -C "$RTSP_TREE" status --porcelain --untracked-files=normal)

  if [[ -e "$RTSP_TREE/libxml2" ]]; then
    require_head "$RTSP_TREE/libxml2" "$LIBXML2_COMMIT"
    require_pristine "$RTSP_TREE/libxml2"
  fi
  if [[ -e "$RTSP_TREE/libxkbcommon" ]]; then
    require_head "$RTSP_TREE/libxkbcommon" "$LIBXKBCOMMON_COMMIT"
    require_pristine "$RTSP_TREE/libxkbcommon"
  fi
  if [[ -e "$RTSP_TREE/wayland-protocols" ]]; then
    require_head "$RTSP_TREE/wayland-protocols" "$WAYLAND_PROTOCOLS_COMMIT"
    require_pristine "$RTSP_TREE/wayland-protocols"
  fi
}

require_expected_untracked_roots() {
  local status_line

  while IFS= read -r status_line; do
    [[ "$status_line" == "?? "* ]] || continue
    case "$status_line" in
      "?? libxml2/"|"?? libxkbcommon/"|"?? locale/"|\
      "?? wayland-protocols/") ;;
      *) fail "$RTSP_TREE contains an unexpected untracked path: ${status_line#\?\? }" ;;
    esac
  done < <(git -C "$RTSP_TREE" status --porcelain --untracked-files=normal)
}

tracked_diff_sha256() {
  local pathspec=(.)

  if [[ "$1" == "root" ]]; then
    pathspec+=(":(exclude,top)wine" ":(exclude,top)piper")
  else
    pathspec=(wineopenxr)
  fi
  git -C "$RTSP_TREE" diff --no-ext-diff --binary --full-index \
    "$RTSP_COMMIT" -- "${pathspec[@]}" \
    | sha256sum | awk '{print $1}'
}

require_gitlink() {
  local tree="$1"
  local path="$2"
  local expected="$3"
  local mode type actual name

  read -r mode type actual name < <(git -C "$tree" ls-tree HEAD -- "$path")
  [[ "$mode" == "160000" && "$type" == "commit" && "$actual" == "$expected" ]] \
    || fail "$tree:$path is not the expected gitlink $expected"
}

require_sha256() {
  local path="$1"
  local expected="$2"
  local actual

  [[ -s "$path" ]] || fail "missing or empty input: $path"
  actual="$(sha256sum "$path")"
  actual="${actual%% *}"
  [[ "$actual" == "$expected" ]] \
    || fail "$path has SHA-256 $actual, expected $expected"
}

fetch_dep() {
  local name="$1"
  local url="$2"
  local commit="$3"
  local path="$RTSP_TREE/$name"

  if [[ -d "$path/.git" ]] || [[ -f "$path/.git" ]]; then
    require_head "$path" "$commit"
    [[ -z "$(git -C "$path" status --porcelain)" ]] \
      || fail "$path contains local changes"
    return
  fi
  [[ ! -e "$path" ]] || fail "$path exists but is not a Git checkout"
  git -c maintenance.auto=false -c gc.auto=0 clone --filter=blob:none --no-checkout "$url" "$path"
  git -c maintenance.auto=false -c gc.auto=0 -C "$path" fetch --filter=blob:none --depth=1 origin "$commit"
  git -C "$path" checkout --detach "$commit"
}

mkdir -p "$WORK_ROOT"
# Preparation is transactional: no prior success marker may survive any new
# attempt, including one that fails or is interrupted halfway through.
rm -f -- "$PREPARED_STATE"

RTSP_TREE="$(prepared_state_canonical_dir "$RTSP_TREE")" \
  || fail "RTSP source tree does not exist: $RTSP_TREE"
GE_TREE="$(prepared_state_canonical_dir "$GE_TREE")" \
  || fail "GE source tree does not exist: $GE_TREE"
WINE_TREE="$RTSP_TREE/wine"
PIPER_TREE="$RTSP_TREE/piper"
XALIA_TREE="$SOURCES_DIR/xalia"

require_head "$RTSP_TREE" "$RTSP_COMMIT"
require_head "$GE_TREE" "$GE_COMMIT"
require_head "$WINE_TREE" "$RTSP_WINE_BASE"
require_head "$PIPER_TREE" "$RTSP_PIPER_COMMIT"
require_initial_rtsp
require_pristine "$WINE_TREE"
require_pristine "$PIPER_TREE"
require_pristine "$GE_TREE"
require_gitlink "$RTSP_TREE" wine "$RTSP_WINE_BASE"
require_gitlink "$RTSP_TREE" piper "$RTSP_PIPER_COMMIT"
[[ "$(git -C "$GE_TREE" rev-parse 'HEAD^{tree}')" == "$GE_ROOT_TREE" ]] \
  || fail "pinned GE root tree does not match the source lock"
[[ "$(git -C "$GE_TREE" rev-parse 'HEAD:locale')" == "$GE_LOCALE_TREE" ]] \
  || fail "pinned GE locale tree does not match the source lock"
[[ "$(git -C "$GE_TREE" rev-parse "HEAD:patches/wine-hotfixes/wine-wayland")" == "$GE_WAYLAND_PATCH_TREE" ]] \
  || fail "pinned GE Wayland patch tree does not match the source lock"
[[ "$(git -C "$GE_TREE" rev-parse "HEAD:patches/wineopenxr/wineopenxr_decouple.patch")" == "$GE_WINEOPENXR_BLOB" ]] \
  || fail "pinned GE WineOpenXR blob does not match the source lock"
[[ "$(git -C "$GE_TREE" ls-tree HEAD wine | awk '$1 == "160000" {print $3}')" == "$GE_WINE_COMMIT" ]] \
  || fail "pinned GE Wine gitlink does not match the source lock"
require_gitlink "$GE_TREE" piper "$RTSP_PIPER_COMMIT"
require_gitlink "$GE_TREE" libxml2 "$LIBXML2_COMMIT"
require_gitlink "$GE_TREE" libxkbcommon "$LIBXKBCOMMON_COMMIT"
require_gitlink "$GE_TREE" wayland-protocols "$WAYLAND_PROTOCOLS_COMMIT"
[[ -d "$PATCH_BUNDLE" ]] || fail "missing GE Wayland patch bundle: $PATCH_BUNDLE"
[[ -f "$OPENXR_PATCH" ]] || fail "missing GE WineOpenXR patch: $OPENXR_PATCH"
[[ "$(sha256sum "$OPENXR_PATCH" | awk '{print $1}')" == "$GE_WINEOPENXR_SHA256" ]] \
  || fail "bundled GE WineOpenXR patch hash does not match the source lock"
require_sha256 "$OPENXR_INTEGRATION_PATCH" "$RTSP_WINEOPENXR_INTEGRATION_SHA256"
mapfile -t WAYLAND_PATCHES < <(
  find "$PATCH_BUNDLE" -maxdepth 1 -type f -name '*.patch' -print | LC_ALL=C sort
)
[[ "${#WAYLAND_PATCHES[@]}" == "$GE_WAYLAND_PATCH_COUNT" ]] \
  || fail "expected $GE_WAYLAND_PATCH_COUNT GE Wayland patches, found ${#WAYLAND_PATCHES[@]}"
require_sha256 "$PIPER_PATCH" "$PIPER_PATCH_SHA256"

git -C "$RTSP_TREE" apply --check "$ROOT_DIR/patches/proton-rtsp-wayland.patch"
git -C "$RTSP_TREE" apply "$ROOT_DIR/patches/proton-rtsp-wayland.patch"
git -C "$RTSP_TREE" apply --check "$ROOT_DIR/patches/proton-alpha2.patch"
git -C "$RTSP_TREE" apply "$ROOT_DIR/patches/proton-alpha2.patch"
grep -Fqx "XALIA_ZIP_SHA256 := $XALIA_ZIP_SHA256" "$RTSP_TREE/Makefile.in" \
  || fail "prepared Makefile does not contain the pinned Xalia archive hash"

git -C "$PIPER_TREE" apply --check "$PIPER_PATCH"
git -C "$PIPER_TREE" apply "$PIPER_PATCH"

for patch_path in "${WAYLAND_PATCHES[@]}"; do
  patch_name="$(basename "$patch_path")"
  upstream_patch="$GE_TREE/patches/wine-hotfixes/wine-wayland/$patch_name"
  [[ -f "$upstream_patch" ]] || fail "pinned GE source is missing patch: $patch_name"
  cmp "$patch_path" "$upstream_patch" \
    || fail "bundled patch differs from pinned GE source: $patch_name"
  git -c user.name='Proton RTSP Wayland Build' \
      -c user.email='build@localhost' \
      -C "$WINE_TREE" am --3way --keep-cr "$patch_path"
done

[[ "$(git -C "$WINE_TREE" rev-list --count "$RTSP_WINE_BASE..HEAD")" == "$GE_WAYLAND_PATCH_COUNT" ]] \
  || fail "Wine patch count does not match the audited series"
[[ "$(git -C "$WINE_TREE" rev-parse 'HEAD^{tree}')" == "$FINAL_WINE_TREE" ]] \
  || fail "prepared Wine tree does not match the deterministic Alpha 2 lock"
require_pristine "$WINE_TREE"

cmp "$OPENXR_PATCH" "$GE_TREE/patches/wineopenxr/wineopenxr_decouple.patch" \
  || fail "bundled WineOpenXR patch differs from pinned GE source"
patch -d "$RTSP_TREE/wineopenxr" -Np1 --batch --forward --dry-run < "$OPENXR_PATCH"
patch -d "$RTSP_TREE/wineopenxr" -Np1 --batch --forward < "$OPENXR_PATCH"
patch -d "$RTSP_TREE/wineopenxr" -Np1 --batch --forward --dry-run < "$OPENXR_INTEGRATION_PATCH"
patch -d "$RTSP_TREE/wineopenxr" -Np1 --batch --forward < "$OPENXR_INTEGRATION_PATCH"

[[ ! -e "$RTSP_TREE/locale" ]] || fail "$RTSP_TREE/locale already exists"
cp -a "$GE_TREE/locale" "$RTSP_TREE/locale"
fetch_dep libxml2 https://gitlab.gnome.org/GNOME/libxml2.git "$LIBXML2_COMMIT"
fetch_dep libxkbcommon https://github.com/xkbcommon/libxkbcommon.git "$LIBXKBCOMMON_COMMIT"
fetch_dep wayland-protocols https://gitlab.freedesktop.org/wayland/wayland-protocols.git "$WAYLAND_PROTOCOLS_COMMIT"

require_head "$XALIA_TREE" "$XALIA_COMMIT"
require_pristine "$XALIA_TREE"
require_head "$XALIA_TREE/xalia/external/SDL3-CS" "$XALIA_SDL3_CS_COMMIT"
require_pristine "$XALIA_TREE/xalia/external/SDL3-CS"
require_expected_untracked_roots

diff -qr --no-dereference "$GE_TREE/locale" "$RTSP_TREE/locale" > /dev/null \
  || fail "copied locale tree differs from the pinned GE source"
[[ "$(tracked_diff_sha256 root)" == "$FINAL_RTSP_TRACKED_DIFF_SHA256" ]] \
  || fail "prepared Proton tracked diff does not match the Alpha 2 lock"
[[ "$(tracked_diff_sha256 wineopenxr)" == "$FINAL_WINEOPENXR_DIFF_SHA256" ]] \
  || fail "prepared WineOpenXR diff does not match the Alpha 2 lock"

piper_status="$(git -C "$PIPER_TREE" status --porcelain --untracked-files=all)"
[[ "$piper_status" == " M CMakeLists.txt" ]] \
  || fail "Piper contains changes other than the pinned CMakeLists.txt repair"
cmp "$PIPER_PATCH" <(git -C "$PIPER_TREE" diff --no-ext-diff --binary -- CMakeLists.txt) \
  || fail "prepared Piper change differs from the pinned repair"
git -C "$RTSP_TREE" diff --check

prepared_state_write "$PREPARED_STATE" "$RTSP_TREE" "$GE_TREE" \
  || fail "could not write prepared source state"
printf 'RTSP source prepared at %s\n' "$RTSP_TREE"
printf 'GE source: %s (%s, %s)\n' "$GE_COMMIT" "$GE_SOURCE_KIND" "$GE_SOURCE_LABEL"
printf 'GE Wayland patches: %s\n' "$GE_WAYLAND_PATCH_COUNT"
printf 'GE WineOpenXR repair: %s\n' "$GE_WINEOPENXR_PATCH"
printf 'RTSP WineOpenXR build integration: %s\n' "$RTSP_WINEOPENXR_INTEGRATION_PATCH"
printf 'Next: WORK_ROOT=%q %q\n' "$WORK_ROOT" "$ROOT_DIR/scripts/build.sh"
