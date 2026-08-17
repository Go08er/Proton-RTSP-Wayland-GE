<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Patch layout

## Project launcher and build wiring

- `proton-rtsp-wayland.patch` adds the native WineWayland build, xrandr and
  locale packaging, launcher selection, and final DLL-override diagnostics
  while retaining RTSP's media stack. Beta 1 and Beta 2 do not define or
  consume `PROTON_XR_MODE`.
- `proton-alpha2.patch` and `proton-alpha3.patch` preserve the earlier prefix
  transitions.
- `proton-beta1.patch` preserves the published Beta 1 launcher input.
- `proton-beta2.patch` retains the same functional launcher changes while
  identifying the new candidate in its patch metadata.
- `piper-phonemize-pin.patch` replaces Piper's mutable dependency URL with the
  exact commit and archive hash used by the build.

## Exact GE-Proton11-5 material

- `ge-proton11-5-wayland/` contains 152 selected format patches copied
  byte-for-byte from the exact `GE-Proton11-5` release.
- `ge-proton11-5-selection.md` records the selected ranges, exclusions,
  subject delta, context-only adapter, and replay proof.
- `ge-proton11-3-wayland/` and `ge-proton11-3-selection.md` remain as the
  published Beta 1 provenance record and the buildable RTSP-only checkpoint's
  input; they are not part of Beta 2's active replay.
- `wineopenxr-decouple-ge-proton11-3.patch` is the exact
  `patches/wineopenxr/wineopenxr_decouple.patch` retained unchanged because
  its blob is identical in GE-Proton11-5.

Preparation verifies both annotated upstream tags, their release commits,
relevant Git trees and blobs, and every bundled GE patch before replay.

## Layout adapters and local repair

- `winebus-no-steaminput-ge-proton11-5-rtsp-adapter.patch` preserves upstream
  `0092` with its seven inserted lines unchanged and only its evolved Winebus
  hunk context adjusted for the RTSP Wine base.
- `wineopenxr-rtsp-makedep-integration.patch` removes one redundant
  `UNIX_LIBS` assignment. RTSP's makedep wrapper must retain its `ntdll.so`
  input while the top-level build supplies OpenXR loader flags.
- `wineopenxr-session-lifetime-ge-proton11-3.patch` is a source-equivalent
  backport of GE-Proton11-3's four-line destroyed-session list cleanup.
- `winewayland-steam-input-ge-proton11-3-rtsp-adapter.patch` carries the
  SetupAPI half of GE's stale Steam desktop virtual-controller filter. RTSP's
  older cfgmgr32 implementation forwards the affected enumeration calls into
  SetupAPI, so importing GE's newer standalone cfgmgr32 hunk would duplicate
  the policy.
- `winewayland-advertise-wine-vr-device-extensions.patch` is the
  project-authored repair introduced for Alpha 4 and retained in Beta 2. It
  makes WineWayland advertise the same
  synthetic `VK_WINE_openvr_device_extensions` and
  `VK_WINE_openxr_device_extensions` capabilities already exposed by Wine's
  X11 path.

The active Wine replay is 152 exact GE patches followed by the Winebus context
adapter, the unchanged SetupAPI Steam Input adapter, and the two-line XR
capability repair: 155 commits total. The final tree is recorded in
`config/upstream-pins.sh` after a fresh replay on the pinned RTSP Wine base.

The GE video-rework directory is intentionally not imported because this
distribution keeps RTSP's media architecture. Generic selected fixes that
also touch media remain part of the audited Wayland series where they apply
cleanly without replacing that stack.
