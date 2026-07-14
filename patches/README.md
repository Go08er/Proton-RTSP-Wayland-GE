<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Patch layout

- `proton-rtsp-wayland.patch` changes the RTSP Proton build wiring and launcher.
  It enables the native Wine Wayland build, packages xrandr and X11 locale
  data, preserves RTSP media wiring, and adds the scoped XRizer launch mode.
- `proton-alpha2.patch` contains the Alpha 2 launcher follow-up, including the
  prefix-version bump and corrected Steam Input override handling.
- `piper-phonemize-pin.patch` replaces Piper's mutable piper-phonemize branch
  URL with the exact commit and SHA-256 used by this build. Piper and this
  modification retain Piper's MIT terms.
- `ge-dev-9fad3bbe-wayland/` contains the 105 Wayland-focused Wine patches used
  by Alpha 2. They are copied verbatim from Proton-GE commit
  `9fad3bbe270409e67a8d2f4d123afc73d848306a`.
- `ge-dev-9fad3bbe-selection.md` records the selected ranges, omission
  categories, and the inclusion decisions most relevant to XR and media.
- `wineopenxr-decouple-9fad3bbe.patch` is the exact
  `patches/wineopenxr/wineopenxr_decouple.patch` from that same Proton-GE
  snapshot. It is applied to RTSP's standalone `wineopenxr` tree.
- `wineopenxr-rtsp-makedep-integration.patch` removes the GE patch's redundant
  `UNIX_LIBS` assignment on this RTSP build system. RTSP's makedep wrapper must
  inject `ntdll.so`; the OpenXR loader remains supplied by the top-level
  `WINEOPENXR_LDFLAGS`. Without this one-line adapter, the later assignment
  overwrites `ntdll.so` and the Unix bridge fails to link.
- `ge11-wayland-series.txt` and `ge11-wayland/` retain the prior Alpha 1 patch
  selection for historical review. Alpha 2 does not apply them.

`scripts/apply-patches.sh` compares every bundled GE-derived patch byte-for-byte
with the pinned Proton-GE checkout before applying the active Wayland set with
`git am`.
It verifies that the resulting Wine history is exactly 105 commits above the
pinned RTSP Wine base and compares the WineOpenXR repair byte-for-byte before
applying it, then applies and hash-checks the RTSP-specific one-line adapter.

The active snapshot name, immutable commit, bundle directory, patch count, and
WineOpenXR filename are defined in `config/upstream-pins.sh`. The snapshot was
selected from Proton-GE `master` on 2026-07-13; it is development state, not
GE-Proton11-2. The release-pin swap must regenerate and re-audit both active GE
bundles rather than simply relabeling these files.
