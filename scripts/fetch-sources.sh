#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_ROOT="${WORK_ROOT:-/tmp/proton-rtsp-wayland-ge-work}"
SOURCES_DIR="${SOURCES_DIR:-$WORK_ROOT/sources}"

RTSP_REPO="https://github.com/SpookySkeletons/proton-ge-rtsp.git"
RTSP_COMMIT="3b4a5f407a5e0cabeef6d3757f29a23f277b429a"
GE_REPO="https://github.com/GloriousEggroll/proton-ge-custom.git"
GE_COMMIT="fd07a035fadfbe989aef887cb999d0ef236c50d0"
XALIA_REPO="https://github.com/madewokherd/xalia.git"
XALIA_COMMIT="6d946216c29052c29c660ad4cac950a6bd08a2b4"
XALIA_SDL3_CS_COMMIT="e26a111c1b90301e37475a4dfb6f5ce47447d677"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

git_safe() {
  git -c maintenance.auto=false -c maintenance.autoDetach=false \
    -c gc.auto=0 -c gc.autoDetach=false "$@"
}

clone_at_commit() {
  local name="$1"
  local url="$2"
  local commit="$3"
  local path="$SOURCES_DIR/$name"

  if [[ ! -d "$path/.git" ]]; then
    git_safe clone --filter=blob:none --no-checkout "$url" "$path"
  else
    [[ -z "$(git -C "$path" status --porcelain)" ]] \
      || fail "$path contains local changes"
  fi

  git_safe -C "$path" fetch --filter=blob:none --depth=1 origin "$commit"
  git_safe -C "$path" checkout --detach "$commit"
}

mkdir -p "$SOURCES_DIR"
clone_at_commit proton-ge-rtsp "$RTSP_REPO" "$RTSP_COMMIT"
clone_at_commit proton-ge-custom "$GE_REPO" "$GE_COMMIT"
clone_at_commit xalia "$XALIA_REPO" "$XALIA_COMMIT"

git_safe -C "$SOURCES_DIR/proton-ge-rtsp" submodule update --init --recursive
git_safe -C "$SOURCES_DIR/xalia" submodule update --init --recursive

actual_sdl3_cs="$(git -C "$SOURCES_DIR/xalia/xalia/external/SDL3-CS" rev-parse HEAD)"
[[ "$actual_sdl3_cs" == "$XALIA_SDL3_CS_COMMIT" ]] \
  || fail "Xalia SDL3-CS is at $actual_sdl3_cs, expected $XALIA_SDL3_CS_COMMIT"

printf 'Pinned sources are ready under %s\n' "$SOURCES_DIR"
printf 'Next: WORK_ROOT=%q %q\n' "$WORK_ROOT" "$ROOT_DIR/scripts/apply-patches.sh"
