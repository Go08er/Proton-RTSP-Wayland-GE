#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/config/upstream-pins.sh"
source "$ROOT_DIR/scripts/lib/prepared-state.sh"
[[ $# == 2 ]] || { echo "usage: $0 RTSP_SOURCE GE_SOURCE" >&2; exit 1; }
rtsp="$(prepared_state_canonical_dir "$1")"
ge="$(prepared_state_canonical_dir "$2")"

must_reject() {
  if "$@"; then
    printf 'FAIL: accepted invalid input: %s\n' "$*" >&2
    exit 1
  fi
}

prepared_require_tag "$rtsp" "$RTSP_SOURCE_LABEL" "$RTSP_TAG_TYPE" "$RTSP_TAG_OBJECT" "$RTSP_COMMIT"
prepared_require_tag "$ge" "$GE_SOURCE_LABEL" "$GE_TAG_TYPE" "$GE_TAG_OBJECT" "$GE_COMMIT"
must_reject prepared_require_tag "$rtsp" "$RTSP_SOURCE_LABEL" tag "$RTSP_TAG_OBJECT" "$RTSP_COMMIT"
must_reject prepared_require_tag "$ge" "$GE_SOURCE_LABEL" commit "$GE_TAG_OBJECT" "$GE_COMMIT"
for spec in rtsp ge; do
  if [[ "$spec" == rtsp ]]; then
    tree="$rtsp"; label="$RTSP_SOURCE_LABEL"; type="$RTSP_TAG_TYPE"; object="$RTSP_TAG_OBJECT"; commit="$RTSP_COMMIT"
  else
    tree="$ge"; label="$GE_SOURCE_LABEL"; type="$GE_TAG_TYPE"; object="$GE_TAG_OBJECT"; commit="$GE_COMMIT"
  fi
  must_reject prepared_require_tag "$tree" "$label" "$type" wrong-object "$commit"
  must_reject prepared_require_tag "$tree" "$label" "$type" "$object" wrong-commit
done
echo 'PASS: both real tag types accepted; six type/object/commit mismatches rejected'

scratch="$(mktemp -d "${TMPDIR:-/tmp}/beta4-preparation-gates.XXXXXX")"
trap 'rm -rf -- "$scratch"' EXIT
prepared_state_write "$scratch/prepared" "$rtsp" "$ge"
prepared_state_validate "$scratch/prepared" "$rtsp" "$ge"
RTSP_TAG_TYPE=tag must_reject prepared_state_validate "$scratch/prepared" "$rtsp" "$ge"
GE_FOCUS_ADAPTER_SHA256=wrong must_reject prepared_state_validate "$scratch/prepared" "$rtsp" "$ge"
GE_FOLLOWUP_MANIFEST_SHA256=wrong must_reject prepared_state_validate "$scratch/prepared" "$rtsp" "$ge"
must_reject prepared_state_validate "$scratch/prepared" "$ge" "$rtsp"
echo 'PASS: prepared marker accepts matching inputs and rejects changed type, adapter, follow-ups and paths'

python3 - "$ROOT_DIR" <<'PY'
from pathlib import Path
import sys
root = Path(sys.argv[1]) / "patches"
pairs = (
    ("ge-proton11-7-wayland/0196-winewayland-Implement-focus-changes-through-pGetWind.patch",
     "winewayland-focus-ge-proton11-7-rtsp-adapter.patch"),
    ("ge-proton11-7-followups/0048-winewayland-preserve-em11-output-and-token-lifetimes.patch",
     "winewayland-lifetimes-ge-proton11-7-rtsp-adapter.patch"),
)
def changes(path):
    diff = path.read_text().split("diff --git ", 1)[1]
    return [line for line in diff.splitlines()
            if line.startswith(("+", "-"))
            and not line.startswith(("+++", "---", "-- "))]
for original, adapter in pairs:
    assert changes(root / original) == changes(root / adapter), adapter
print("PASS: both adapters retain every upstream added/removed line in order")
PY
