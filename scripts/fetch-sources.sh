#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_ROOT="${WORK_ROOT:-/tmp/proton-rtsp-wayland-ge-beta3-20260609-3}"
SOURCES_DIR="${SOURCES_DIR:-$WORK_ROOT/sources}"
source "$ROOT_DIR/config/upstream-pins.sh"

RTSP_REPO="https://github.com/SpookySkeletons/Proton-RTSP.git"
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

fetch_annotated_tag() {
  local path="$1"
  local label="$2"
  local expected_object="$3"
  local expected_commit="$4"
  local actual_object actual_type actual_commit

  git_safe -C "$path" fetch --filter=blob:none --depth=1 \
    origin "refs/tags/$label:refs/tags/$label"
  actual_object="$(git -C "$path" rev-parse "refs/tags/$label")"
  actual_type="$(git -C "$path" cat-file -t "$actual_object")"
  actual_commit="$(git -C "$path" rev-parse "refs/tags/$label^{}")"
  [[ "$actual_type" == "tag" && "$actual_object" == "$expected_object" ]] \
    || fail "$label is not the expected annotated tag object $expected_object"
  [[ "$actual_commit" == "$expected_commit" ]] \
    || fail "$label peels to $actual_commit, expected $expected_commit"
}

mkdir -p "$WORK_ROOT" "$SOURCES_DIR"
# Any fetch attempt invalidates a prior preparation result, including a failed
# or interrupted attempt.  apply-patches.sh writes a new state only at the end.
rm -f -- "$WORK_ROOT/.prepared"
clone_at_commit proton-ge-rtsp "$RTSP_REPO" "$RTSP_COMMIT"
clone_at_commit proton-ge-custom "$GE_REPO" "$GE_COMMIT"
clone_at_commit xalia "$XALIA_REPO" "$XALIA_COMMIT"

fetch_annotated_tag "$SOURCES_DIR/proton-ge-rtsp" \
  "$RTSP_SOURCE_LABEL" "$RTSP_TAG_OBJECT" "$RTSP_COMMIT"
fetch_annotated_tag "$SOURCES_DIR/proton-ge-custom" \
  "$GE_SOURCE_LABEL" "$GE_TAG_OBJECT" "$GE_COMMIT"

git_safe -C "$SOURCES_DIR/proton-ge-rtsp" submodule update --init --recursive
git_safe -C "$SOURCES_DIR/xalia" submodule update --init --recursive

actual_sdl3_cs="$(git -C "$SOURCES_DIR/xalia/xalia/external/SDL3-CS" rev-parse HEAD)"
[[ "$actual_sdl3_cs" == "$XALIA_SDL3_CS_COMMIT" ]] \
  || fail "Xalia SDL3-CS is at $actual_sdl3_cs, expected $XALIA_SDL3_CS_COMMIT"

printf 'Pinned sources are ready under %s\n' "$SOURCES_DIR"
printf 'GE source: %s (%s, %s)\n' "$GE_COMMIT" "$GE_SOURCE_KIND" "$GE_SOURCE_LABEL"
printf 'Next: WORK_ROOT=%q %q\n' "$WORK_ROOT" "$ROOT_DIR/scripts/apply-patches.sh"
