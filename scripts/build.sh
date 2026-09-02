#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_ROOT="${WORK_ROOT:-/tmp/proton-rtsp-wayland-ge-beta3-20260609-3}"
SOURCES_DIR="${SOURCES_DIR:-$WORK_ROOT/sources}"
RTSP_TREE="${RTSP_TREE:-$SOURCES_DIR/proton-ge-rtsp}"
GE_TREE="${GE_TREE:-$SOURCES_DIR/proton-ge-custom}"
source "$ROOT_DIR/config/upstream-pins.sh"
source "$ROOT_DIR/scripts/lib/prepared-state.sh"
BUILD_NAME="${BUILD_NAME:-Proton-RTSP-Wayland-GE-Beta3}"
DISPLAY_NAME="${DISPLAY_NAME:-Proton RTSP Wayland GE Beta 3}"
JOBS="${JOBS:-1}"
ORCHESTRATOR_JOBS="${ORCHESTRATOR_JOBS:-}"
COMPONENT_JOBS="${COMPONENT_JOBS:-}"
PACKAGE_RELEASE="${PACKAGE_RELEASE:-0}"
DIST_DIR="${DIST_DIR:-$ROOT_DIR/dist}"
PIPER_PHONEME_PATH_LIMIT=274
PREPARED_STATE="$WORK_ROOT/.prepared"
PIPER_PATCH="$ROOT_DIR/patches/piper-phonemize-pin.patch"
OPENXR_INTEGRATION_PATCH="$ROOT_DIR/patches/$RTSP_WINEOPENXR_INTEGRATION_PATCH"
OPENXR_SESSION_PATCH="$ROOT_DIR/patches/$RTSP_WINEOPENXR_SESSION_PATCH"
WINEBUS_NO_STEAMINPUT_ADAPTER_PATCH="$ROOT_DIR/patches/$GE_WINEBUS_NO_STEAMINPUT_ADAPTER_PATCH"
STEAM_INPUT_ADAPTER_PATCH="$ROOT_DIR/patches/$RTSP_STEAM_INPUT_ADAPTER_PATCH"
WINEWAYLAND_XR_PATCH="$ROOT_DIR/patches/$RTSP_WINEWAYLAND_XR_PATCH"
WAYLAND_CURSOR_PATCH="$ROOT_DIR/patches/$GE_WAYLAND_CURSOR_PATCH"
BETA3_PATCH="$ROOT_DIR/patches/$PROTON_BETA3_PATCH"

if [[ "${LOW_IMPACT_REEXEC:-0}" != "1" ]]; then
  export LOW_IMPACT_REEXEC=1
  if command -v ionice >/dev/null 2>&1; then
    exec ionice -c3 nice -n 19 bash "$0" "$@"
  fi
  exec nice -n 19 bash "$0" "$@"
fi

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

[[ "$JOBS" =~ ^[1-9][0-9]*$ ]] \
  || fail "JOBS must be a positive integer"
if [[ -z "$ORCHESTRATOR_JOBS" ]]; then
  if (( JOBS < 4 )); then
    ORCHESTRATOR_JOBS=1
  else
    ORCHESTRATOR_JOBS=$((JOBS / 2))
  fi
fi
if [[ -z "$COMPONENT_JOBS" ]]; then
  COMPONENT_JOBS=$((JOBS / ORCHESTRATOR_JOBS))
fi
[[ "$ORCHESTRATOR_JOBS" =~ ^[1-9][0-9]*$ \
    && "$COMPONENT_JOBS" =~ ^[1-9][0-9]*$ ]] \
  || fail "ORCHESTRATOR_JOBS and COMPONENT_JOBS must be positive integers"
(( ORCHESTRATOR_JOBS * COMPONENT_JOBS <= JOBS )) \
  || fail "nested worker budget exceeds JOBS ($ORCHESTRATOR_JOBS x $COMPONENT_JOBS > $JOBS)"

BUILD_LOCK="${PROTON_BUILD_LOCK:-${HOME:?HOME must be set}/Documents/.proton-build.lock}"
mkdir -p "$(dirname "$BUILD_LOCK")"
exec 9>"$BUILD_LOCK"
flock -n 9 || fail "another cooperating Proton build holds $BUILD_LOCK"

require_head() {
  local tree="$1"
  local expected="$2"
  local actual

  actual="$(git -C "$tree" rev-parse HEAD)"
  [[ "$actual" == "$expected" ]] \
    || fail "$tree is at $actual, expected $expected"
}

require_pristine() {
  local tree="$1"

  [[ -z "$(git -C "$tree" status --porcelain --untracked-files=all)" ]] \
    || fail "$tree contains changes after preparation"
}

require_expected_untracked_roots() {
  local status_line

  while IFS= read -r status_line; do
    [[ "$status_line" == "?? "* ]] || continue
    case "$status_line" in
      "?? contrib/"|"?? libxml2/"|"?? libxkbcommon/"|"?? locale/"|\
      "?? wayland-protocols/") ;;
      *) fail "$RTSP_TREE contains an unexpected untracked path: ${status_line#\?\? }" ;;
    esac
  done < <(git -C "$RTSP_TREE" status --porcelain --untracked-files=normal)
}

require_contrib_cache() {
  local entry name expected actual

  [[ -e "$RTSP_TREE/contrib" ]] || return 0
  [[ -d "$RTSP_TREE/contrib" && ! -L "$RTSP_TREE/contrib" ]] \
    || fail "contrib cache is not a real directory"
  while IFS= read -r -d '' entry; do
    [[ -f "$entry" && ! -L "$entry" ]] \
      || fail "unsupported entry in contrib cache: $entry"
    name="$(basename "$entry")"
    case "$name" in
      "$WINE_GECKO_X86_NAME") expected="$WINE_GECKO_X86_SHA256" ;;
      "$WINE_GECKO_X86_64_NAME") expected="$WINE_GECKO_X86_64_SHA256" ;;
      "$WINE_MONO_X86_NAME") expected="$WINE_MONO_X86_SHA256" ;;
      "$XALIA_ZIP_NAME") expected="$XALIA_ZIP_SHA256" ;;
      "$XRANDR_NAME") expected="$XRANDR_SHA256" ;;
      *) fail "unexpected build-time archive in contrib cache: $name" ;;
    esac
    actual="$(sha256sum "$entry" | awk '{print $1}')"
    [[ "$actual" == "$expected" ]] \
      || fail "$name has SHA-256 $actual, expected $expected"
  done < <(find "$RTSP_TREE/contrib" -mindepth 1 -maxdepth 1 -print0)
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

RTSP_TREE="$(prepared_state_canonical_dir "$RTSP_TREE")" \
  || fail "prepared RTSP source tree is missing"
GE_TREE="$(prepared_state_canonical_dir "$GE_TREE")" \
  || fail "pinned GE source tree is missing"
prepared_state_validate "$PREPARED_STATE" "$RTSP_TREE" "$GE_TREE" \
  || fail "prepared source state is missing or does not match the exact pins and canonical paths"

WINE_TREE="$RTSP_TREE/wine"
PIPER_TREE="$RTSP_TREE/piper"
XALIA_TREE="$SOURCES_DIR/xalia"
TOOL_DIR="$RTSP_TREE/build/$BUILD_NAME"
PIPER_PHONEME_PATH="$RTSP_TREE/build/build-$BUILD_NAME/obj-piper-x86_64/p/src/piper_phonemize_external-build/e/src/espeak_ng_external-build/espeak-ng-data/../phsource/vwl_en_us_nyc/a_raised"

require_head "$RTSP_TREE" "$RTSP_COMMIT"
require_head "$GE_TREE" "$GE_COMMIT"
[[ "$(git -C "$GE_TREE" rev-parse 'HEAD^{tree}')" == "$GE_ROOT_TREE" ]] \
  || fail "GE source tree no longer matches the recorded state"
[[ "$(git -C "$GE_TREE" rev-parse 'HEAD:locale')" == "$GE_LOCALE_TREE" ]] \
  || fail "GE locale tree no longer matches the recorded state"
[[ "$(tracked_diff_sha256 root)" == "$FINAL_RTSP_TRACKED_DIFF_SHA256" ]] \
  || fail "Proton tracked diff no longer matches the prepared Beta 3 state"
[[ "$(tracked_diff_sha256 wineopenxr)" == "$FINAL_WINEOPENXR_DIFF_SHA256" ]] \
  || fail "WineOpenXR diff no longer matches the prepared Beta 3 state"
diff -qr --no-dereference "$GE_TREE/locale" "$RTSP_TREE/locale" > /dev/null \
  || fail "copied locale tree no longer matches the pinned GE source"
[[ "$(git -C "$WINE_TREE" rev-parse 'HEAD^{tree}')" == "$FINAL_WINE_TREE" ]] \
  || fail "Wine source tree no longer matches the deterministic Beta 3 lock"
[[ "$(git -C "$WINE_TREE" rev-list --count "$RTSP_WINE_BASE..HEAD")" == \
    "$FINAL_WINE_PATCH_COUNT" ]] \
  || fail "Wine source history no longer matches the Beta 3 patch count"
require_pristine "$WINE_TREE"
require_head "$PIPER_TREE" "$RTSP_PIPER_COMMIT"
[[ "$(git -C "$PIPER_TREE" status --porcelain --untracked-files=all)" == " M CMakeLists.txt" ]] \
  || fail "Piper source no longer contains only the pinned repair"
cmp "$PIPER_PATCH" <(git -C "$PIPER_TREE" diff --no-ext-diff --binary -- CMakeLists.txt) \
  || fail "Piper repair no longer matches the pinned patch"
[[ "$(sha256sum "$PIPER_PATCH" | awk '{print $1}')" == "$PIPER_PATCH_SHA256" ]] \
  || fail "Piper patch no longer matches its source lock"
[[ -f "$OPENXR_INTEGRATION_PATCH" ]] \
  || fail "WineOpenXR integration patch is missing"
[[ "$(sha256sum "$OPENXR_INTEGRATION_PATCH" | awk '{print $1}')" == "$RTSP_WINEOPENXR_INTEGRATION_SHA256" ]] \
  || fail "WineOpenXR integration patch no longer matches its source lock"
[[ "$(sha256sum "$OPENXR_SESSION_PATCH" | awk '{print $1}')" == "$RTSP_WINEOPENXR_SESSION_SHA256" ]] \
  || fail "WineOpenXR session patch no longer matches its source lock"
[[ "$(sha256sum "$WINEBUS_NO_STEAMINPUT_ADAPTER_PATCH" | awk '{print $1}')" == "$GE_WINEBUS_NO_STEAMINPUT_ADAPTER_SHA256" ]] \
  || fail "Winebus Steam Input adapter no longer matches its source lock"
[[ "$(sha256sum "$STEAM_INPUT_ADAPTER_PATCH" | awk '{print $1}')" == "$RTSP_STEAM_INPUT_ADAPTER_SHA256" ]] \
  || fail "Steam Input adapter no longer matches its source lock"
[[ "$(sha256sum "$WINEWAYLAND_XR_PATCH" | awk '{print $1}')" == "$RTSP_WINEWAYLAND_XR_SHA256" ]] \
  || fail "WineWayland XR patch no longer matches its source lock"
[[ "$(sha256sum "$WAYLAND_CURSOR_PATCH" | awk '{print $1}')" == "$GE_WAYLAND_CURSOR_PATCH_SHA256" ]] \
  || fail "GE WineWayland cursor patch no longer matches its source lock"
[[ "$(sha256sum "$BETA3_PATCH" | awk '{print $1}')" == "$PROTON_BETA3_SHA256" ]] \
  || fail "Beta 3 launcher patch no longer matches its source lock"
grep -Fqx 'CURRENT_PREFIX_VERSION="11.0-104"' "$RTSP_TREE/proton" \
  || fail "expected 11.0-104 prefix identity is missing"
grep -Fq 'self.env["PROTON_NO_STEAMINPUT"] = "1"' "$RTSP_TREE/proton" \
  || fail "$GE_SOURCE_LABEL WineWayland Steam Input policy is missing"
grep -Fq 'list_remove(&wine_session->entry);' "$RTSP_TREE/wineopenxr/openxr_loader.c" \
  || fail "WineOpenXR session-list cleanup is missing"
require_head "$RTSP_TREE/libxml2" "$LIBXML2_COMMIT"
require_pristine "$RTSP_TREE/libxml2"
require_head "$RTSP_TREE/libxkbcommon" "$LIBXKBCOMMON_COMMIT"
require_pristine "$RTSP_TREE/libxkbcommon"
require_head "$RTSP_TREE/wayland-protocols" "$WAYLAND_PROTOCOLS_COMMIT"
require_pristine "$RTSP_TREE/wayland-protocols"
require_head "$XALIA_TREE" "$XALIA_COMMIT"
require_pristine "$XALIA_TREE"
require_head "$XALIA_TREE/xalia/external/SDL3-CS" "$XALIA_SDL3_CS_COMMIT"
require_pristine "$XALIA_TREE/xalia/external/SDL3-CS"
require_contrib_cache
require_expected_untracked_roots
grep -Fqx "XALIA_ZIP_SHA256 := $XALIA_ZIP_SHA256" "$RTSP_TREE/Makefile.in" \
  || fail "prepared Makefile no longer enforces the pinned Xalia archive hash"

[[ -x "$RTSP_TREE/configure.sh" ]] || fail "prepared RTSP source is missing"
if (( ${#PIPER_PHONEME_PATH} > PIPER_PHONEME_PATH_LIMIT )); then
  fail "build path is too long for eSpeak NG's phoneme compiler (${#PIPER_PHONEME_PATH} > $PIPER_PHONEME_PATH_LIMIT characters); use a shorter neutral WORK_ROOT such as /tmp/proton-rtsp-wayland-ge-beta3-20260609-3"
fi

if [[ ! -f "$RTSP_TREE/build/build-$BUILD_NAME/Makefile" ]]; then
  mkdir -p "$RTSP_TREE/build/build-$BUILD_NAME"
  (
    cd "$RTSP_TREE/build/build-$BUILD_NAME"
    ../../configure.sh --build-name="$BUILD_NAME" --enable-ccache
  )
fi

(
  cd "$RTSP_TREE"
  # GNU Make orchestrates several architecture/component recipes at once, and
  # each Meson recipe starts its own Ninja.  Split the global budget across
  # those two layers so, for example, JOBS=12 means at most 6 x 2 workers,
  # not 12 x 12.  J also controls Wine submakes and packaging helpers, so it
  # must use the orchestrator share rather than the global nested budget.
  MAKEFLAGS="-j$ORCHESTRATOR_JOBS" \
    make J="$ORCHESTRATOR_JOBS" \
      NINJA_JOBS="$COMPONENT_JOBS" \
      CMAKE_BUILD_PARALLEL_LEVEL="$COMPONENT_JOBS" \
      CARGO_BUILD_JOBS="$COMPONENT_JOBS" \
      NIX_BUILD_CORES="$COMPONENT_JOBS" \
      "build_name=$BUILD_NAME" redist
)

read -r build_epoch rtsp_version < "$TOOL_DIR/version"
[[ "$build_epoch" =~ ^[0-9]+$ && "$rtsp_version" == proton-rtsp-* \
    && "$rtsp_version" != *[[:space:]]* ]] \
  || fail "generated version does not contain the expected RTSP identity"
printf '%s %s+%s+%s\n' \
  "$build_epoch" "$BUILD_NAME" "$rtsp_version" "$GE_SOURCE_LABEL" \
  > "$TOOL_DIR/version"

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

BUILD_NAME="$BUILD_NAME" \
DISPLAY_NAME="$DISPLAY_NAME" \
GE_SOURCE_LABEL="$GE_SOURCE_LABEL" \
  "$ROOT_DIR/scripts/verify.sh" "$TOOL_DIR"

if [[ "$PACKAGE_RELEASE" != "1" ]]; then
  printf 'Game-test directory: %s\n' "$TOOL_DIR"
  printf 'Packaging skipped (set PACKAGE_RELEASE=1 after acceptance).\n'
  exit 0
fi

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
