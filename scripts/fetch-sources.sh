#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_ROOT="${WORK_ROOT:-/tmp/proton-rtsp-wayland-ge-beta1-11-3}"
SOURCES_DIR="${SOURCES_DIR:-$WORK_ROOT/sources}"
source "$ROOT_DIR/config/upstream-pins.sh"

RTSP_REPO="https://github.com/SpookySkeletons/proton-ge-rtsp.git"
GE_REPO="https://github.com/GloriousEggroll/proton-ge-custom.git"
XALIA_REPO="https://github.com/madewokherd/xalia.git"

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

mkdir -p "$WORK_ROOT" "$SOURCES_DIR"
# Any fetch attempt invalidates a prior preparation result, including a failed
# or interrupted attempt.  apply-patches.sh writes a new state only at the end.
rm -f -- "$WORK_ROOT/.prepared"
clone_at_commit proton-ge-rtsp "$RTSP_REPO" "$RTSP_COMMIT"
clone_at_commit proton-ge-custom "$GE_REPO" "$GE_COMMIT"
clone_at_commit xalia "$XALIA_REPO" "$XALIA_COMMIT"

git_safe -C "$SOURCES_DIR/proton-ge-custom" fetch --filter=blob:none --depth=1 \
  origin "refs/tags/$GE_SOURCE_LABEL:refs/tags/$GE_SOURCE_LABEL"
actual_ge_tag_object="$(
  git -C "$SOURCES_DIR/proton-ge-custom" rev-parse "refs/tags/$GE_SOURCE_LABEL"
)"
actual_ge_tag_type="$(
  git -C "$SOURCES_DIR/proton-ge-custom" cat-file -t "$actual_ge_tag_object"
)"
actual_ge_tag_commit="$(
  git -C "$SOURCES_DIR/proton-ge-custom" rev-parse "refs/tags/$GE_SOURCE_LABEL^{}"
)"
[[ "$actual_ge_tag_type" == "tag" && "$actual_ge_tag_object" == "$GE_TAG_OBJECT" ]] \
  || fail "$GE_SOURCE_LABEL is not the expected annotated tag object $GE_TAG_OBJECT"
[[ "$actual_ge_tag_commit" == "$GE_COMMIT" ]] \
  || fail "$GE_SOURCE_LABEL peels to $actual_ge_tag_commit, expected $GE_COMMIT"

git_safe -C "$SOURCES_DIR/proton-ge-rtsp" submodule update --init --recursive
git_safe -C "$SOURCES_DIR/xalia" submodule update --init --recursive

actual_sdl3_cs="$(git -C "$SOURCES_DIR/xalia/xalia/external/SDL3-CS" rev-parse HEAD)"
[[ "$actual_sdl3_cs" == "$XALIA_SDL3_CS_COMMIT" ]] \
  || fail "Xalia SDL3-CS is at $actual_sdl3_cs, expected $XALIA_SDL3_CS_COMMIT"

printf 'Pinned sources are ready under %s\n' "$SOURCES_DIR"
printf 'GE source: %s (%s, %s)\n' "$GE_COMMIT" "$GE_SOURCE_KIND" "$GE_SOURCE_LABEL"
printf 'Next: WORK_ROOT=%q %q\n' "$WORK_ROOT" "$ROOT_DIR/scripts/apply-patches.sh"
