#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause
set -euo pipefail

LOG_FILE="${1:-}"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

[[ -n "$LOG_FILE" ]] || fail "usage: $0 /path/to/steam-APPID.log"
[[ -f "$LOG_FILE" ]] || fail "log does not exist: $LOG_FILE"
[[ -s "$LOG_FILE" ]] || fail "log is empty: $LOG_FILE"
command -v rg > /dev/null || fail "ripgrep (rg) is required"

sanitize() {
  sed -E \
    -e 's#/home/[^/[:space:]"]+#/home/<user>#g' \
    -e 's#/run/user/[0-9]+#/run/user/<uid>#g'
}

count_matches() {
  local label="$1"
  local pattern="$2"
  local count

  count="$(rg -c -- "$pattern" "$LOG_FILE" 2>/dev/null || true)"
  printf '%-38s %s\n' "$label" "${count:-0}"
}

show_matches() {
  local heading="$1"
  local limit="$2"
  local pattern="$3"

  printf '\n%s\n' "$heading"
  if ! rg -n -m "$limit" -e "$pattern" "$LOG_FILE" 2>/dev/null | sanitize; then
    printf '(none found)\n'
  fi
}

line_count="$(wc -l < "$LOG_FILE" | tr -d ' ')"
byte_count="$(wc -c < "$LOG_FILE" | tr -d ' ')"

printf 'Proton log summary\n'
printf 'Lines: %s\n' "$line_count"
printf 'Bytes: %s\n' "$byte_count"

show_matches "Launch routing" 20 \
  '^(Proton:|SteamGameId:|Options:|Effective WINEDEBUG:|Final WINEDLLOVERRIDES:)'

show_matches "Graphics and XR lifecycle" 120 \
  'ntsync: up and running|Initializing XRizer version|^[[:space:]]*(Head|Left|Right):|^info:  DXVK: [0-9a-f]|^info:  Found device:|^info:  Creating device:|^info:  (NVIDIA|AMD|Intel|llvmpipe).*:$|DXVK: Using [0-9]+ compiler threads|OpenXR session state changed|Received game texture'

printf '\nSignal counts\n'
count_matches "Wine trace lines" ':trace:'
count_matches "Wine fixme lines" ':fixme:'
count_matches "Wine warning lines" ':warn:'
count_matches "Wine error lines" ':err:'
count_matches "XRizer warnings" '\[[^]]+ WARN +xrizer'
count_matches "XRizer errors" '\[[^]]+ ERROR +xrizer'
count_matches "winewayland.drv loads" '(?i)Loaded .*winewayland\.drv'
count_matches "winex11.drv loads" '(?i)Loaded .*winex11\.drv'
count_matches "wineopenxr.dll loads" '(?i)Loaded .*wineopenxr\.dll'
count_matches "DXVK state-cache hits" 'Found cache file:'
count_matches "Fossilize serialization routes" 'Fossilize INFO: Overriding serialization path:'
count_matches "VK_ERROR occurrences" 'VK_ERROR'
count_matches "Graphics-init failures" 'InitializeEngineGraphics failed'
count_matches "Shared-handle warnings" 'Failed to open shared (NT|D3DKMT) handle'
count_matches "GStreamer critical assertions" 'GStreamer-CRITICAL'

show_matches "High-signal failures and watch items" 80 \
  'InitializeEngineGraphics failed|VK_ERROR|XR_ERROR|[Dd]evice lost|[Oo]ut of (host |device |video )?memory|DxvkContext: Cannot relocate image|Failed to open shared (NT|D3DKMT) handle|GStreamer-CRITICAL|wg_parser_connect: Failed|MESA-LOADER: failed|\[[^]]+ ERROR +xrizer'

printf '\nThis is a fixed-pattern summary, not guaranteed anonymization.\n'
printf 'Inspect this output manually before sharing it. Never publish the raw log by default.\n'
