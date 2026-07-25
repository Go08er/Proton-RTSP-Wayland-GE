<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Patch layout

## Project launcher and build wiring

- `proton-rtsp-wayland.patch` adds the native WineWayland build, xrandr and
  locale packaging, launcher selection, and final DLL-override diagnostics
  while retaining RTSP's media stack. Beta 1 does not define or consume
  `PROTON_XR_MODE`.
- `proton-alpha2.patch` and `proton-alpha3.patch` preserve the earlier prefix
  transitions.
- `proton-beta1.patch` advances the prefix to `11.0-103` and adapts
  GE-Proton11-3's WineWayland Steam Input AppID selection/reset behavior.
- `piper-phonemize-pin.patch` replaces Piper's mutable dependency URL with the
  exact commit and archive hash used by the build.

## Exact GE-Proton11-3 material

- `ge-proton11-3-wayland/` contains 138 selected format patches copied
  byte-for-byte from the exact `GE-Proton11-3` release.
- `ge-proton11-3-selection.md` records the selected ranges and exclusions.
- `wineopenxr-decouple-ge-proton11-3.patch` is the exact
  `patches/wineopenxr/wineopenxr_decouple.patch` from that release.

Preparation verifies the annotated GE tag, the release commit, relevant Git
trees and blobs, and every bundled GE patch before replay.

## Layout adapters and local repair

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
  project-authored repair introduced for Alpha 4 and retained in Beta 1. It
  makes WineWayland advertise the same
  synthetic `VK_WINE_openvr_device_extensions` and
  `VK_WINE_openxr_device_extensions` capabilities already exposed by Wine's
  X11 path.

The active Wine replay is 138 exact GE patches followed by the Steam Input
adapter and the two-line XR capability repair: 140 commits total, final tree
`f795acc107bfff20ee6c9442beb151ed9be4ae84`.

The GE video-rework directory is intentionally not imported because this
distribution keeps RTSP's media architecture. Generic selected fixes that
also touch media remain part of the audited Wayland series where they apply
cleanly without replacing that stack.
