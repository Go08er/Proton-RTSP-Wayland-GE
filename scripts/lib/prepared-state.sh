#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause

# Callers must source config/upstream-pins.sh before this file.  The marker is
# compared byte-for-byte with freshly generated state; it is never evaluated as
# shell input.

prepared_state_canonical_dir() {
  local path="$1"

  [[ -d "$path" ]] || return 1
  (cd "$path" && pwd -P)
}

prepared_state_emit() {
  local rtsp_tree="$1"
  local ge_tree="$2"

  printf 'format=%q\n' "2"
  printf 'rtsp_tree=%q\n' "$rtsp_tree"
  printf 'ge_tree=%q\n' "$ge_tree"
  printf 'rtsp_commit=%q\n' "$RTSP_COMMIT"
  printf 'rtsp_wine_base=%q\n' "$RTSP_WINE_BASE"
  printf 'rtsp_source_label=%q\n' "$RTSP_SOURCE_LABEL"
  printf 'rtsp_tag_object=%q\n' "$RTSP_TAG_OBJECT"
  printf 'rtsp_piper_commit=%q\n' "$RTSP_PIPER_COMMIT"
  printf 'final_wine_tree=%q\n' "$FINAL_WINE_TREE"
  printf 'final_wine_patch_count=%q\n' "$FINAL_WINE_PATCH_COUNT"
  printf 'final_rtsp_tracked_diff_sha256=%q\n' "$FINAL_RTSP_TRACKED_DIFF_SHA256"
  printf 'final_wineopenxr_diff_sha256=%q\n' "$FINAL_WINEOPENXR_DIFF_SHA256"
  printf 'ge_tag_object=%q\n' "$GE_TAG_OBJECT"
  printf 'ge_commit=%q\n' "$GE_COMMIT"
  printf 'ge_root_tree=%q\n' "$GE_ROOT_TREE"
  printf 'ge_source_kind=%q\n' "$GE_SOURCE_KIND"
  printf 'ge_source_label=%q\n' "$GE_SOURCE_LABEL"
  printf 'ge_locale_tree=%q\n' "$GE_LOCALE_TREE"
  printf 'ge_wine_commit=%q\n' "$GE_WINE_COMMIT"
  printf 'ge_wayland_patch_tree=%q\n' "$GE_WAYLAND_PATCH_TREE"
  printf 'ge_wayland_patch_count=%q\n' "$GE_WAYLAND_PATCH_COUNT"
  printf 'ge_wineopenxr_blob=%q\n' "$GE_WINEOPENXR_BLOB"
  printf 'ge_wineopenxr_sha256=%q\n' "$GE_WINEOPENXR_SHA256"
  printf 'rtsp_wineopenxr_integration_patch=%q\n' "$RTSP_WINEOPENXR_INTEGRATION_PATCH"
  printf 'rtsp_wineopenxr_integration_sha256=%q\n' "$RTSP_WINEOPENXR_INTEGRATION_SHA256"
  printf 'ge_wineopenxr_loader_blob=%q\n' "$GE_WINEOPENXR_LOADER_BLOB"
  printf 'ge_wineopenxr_loader_sha256=%q\n' "$GE_WINEOPENXR_LOADER_SHA256"
  printf 'rtsp_wineopenxr_session_patch=%q\n' "$RTSP_WINEOPENXR_SESSION_PATCH"
  printf 'rtsp_wineopenxr_session_sha256=%q\n' "$RTSP_WINEOPENXR_SESSION_SHA256"
  printf 'ge_steam_input_patch_path=%q\n' "$GE_STEAM_INPUT_PATCH_PATH"
  printf 'ge_steam_input_patch_blob=%q\n' "$GE_STEAM_INPUT_PATCH_BLOB"
  printf 'ge_steam_input_patch_sha256=%q\n' "$GE_STEAM_INPUT_PATCH_SHA256"
  printf 'ge_proton_blob=%q\n' "$GE_PROTON_BLOB"
  printf 'ge_proton_sha256=%q\n' "$GE_PROTON_SHA256"
  printf 'ge_winebus_no_steaminput_adapter_patch=%q\n' "$GE_WINEBUS_NO_STEAMINPUT_ADAPTER_PATCH"
  printf 'ge_winebus_no_steaminput_adapter_sha256=%q\n' "$GE_WINEBUS_NO_STEAMINPUT_ADAPTER_SHA256"
  printf 'rtsp_steam_input_adapter_patch=%q\n' "$RTSP_STEAM_INPUT_ADAPTER_PATCH"
  printf 'rtsp_steam_input_adapter_sha256=%q\n' "$RTSP_STEAM_INPUT_ADAPTER_SHA256"
  printf 'rtsp_winewayland_xr_patch=%q\n' "$RTSP_WINEWAYLAND_XR_PATCH"
  printf 'rtsp_winewayland_xr_sha256=%q\n' "$RTSP_WINEWAYLAND_XR_SHA256"
  printf 'proton_beta2_patch=%q\n' "$PROTON_BETA2_PATCH"
  printf 'proton_beta2_sha256=%q\n' "$PROTON_BETA2_SHA256"
  printf 'libxml2_commit=%q\n' "$LIBXML2_COMMIT"
  printf 'libxkbcommon_commit=%q\n' "$LIBXKBCOMMON_COMMIT"
  printf 'wayland_protocols_commit=%q\n' "$WAYLAND_PROTOCOLS_COMMIT"
  printf 'xalia_commit=%q\n' "$XALIA_COMMIT"
  printf 'xalia_sdl3_cs_commit=%q\n' "$XALIA_SDL3_CS_COMMIT"
  printf 'xalia_zip_sha256=%q\n' "$XALIA_ZIP_SHA256"
  printf 'wine_gecko_x86_sha256=%q\n' "$WINE_GECKO_X86_SHA256"
  printf 'wine_gecko_x86_64_sha256=%q\n' "$WINE_GECKO_X86_64_SHA256"
  printf 'wine_mono_x86_sha256=%q\n' "$WINE_MONO_X86_SHA256"
  printf 'xrandr_sha256=%q\n' "$XRANDR_SHA256"
  printf 'piper_phonemize_commit=%q\n' "$PIPER_PHONEMIZE_COMMIT"
  printf 'piper_phonemize_zip_sha256=%q\n' "$PIPER_PHONEMIZE_ZIP_SHA256"
  printf 'piper_patch_sha256=%q\n' "$PIPER_PATCH_SHA256"
}

prepared_state_write() {
  local marker="$1"
  local rtsp_tree="$2"
  local ge_tree="$3"
  local temporary

  temporary="$(mktemp "${marker}.tmp.XXXXXX")" || return 1
  if ! prepared_state_emit "$rtsp_tree" "$ge_tree" > "$temporary"; then
    rm -f -- "$temporary"
    return 1
  fi
  chmod 0600 "$temporary"
  mv -f -- "$temporary" "$marker"
}

prepared_state_validate() {
  local marker="$1"
  local rtsp_tree="$2"
  local ge_tree="$3"

  [[ -s "$marker" ]] || return 1
  cmp -s -- "$marker" <(prepared_state_emit "$rtsp_tree" "$ge_tree")
}
