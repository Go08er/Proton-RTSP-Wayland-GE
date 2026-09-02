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
- `proton-beta2.patch` preserves the published Beta 2 launcher input.
- `proton-beta3.patch` retains the same functional launcher changes while
  identifying the Beta 3 candidate in its patch metadata.
- `piper-phonemize-pin.patch` replaces Piper's mutable dependency URL with the
  exact commit and archive hash used by the build.

## Exact GE-Proton11-6 material

- `ge-proton11-6-wayland/` contains 160 selected format patches copied
  byte-for-byte from the exact `GE-Proton11-6` release.
- `winewayland-render-ddb-cursors-ge-proton11-6.patch` is the exact independent
  GE-Proton11-6 `em-fixups` repair for unsupported DDB cursor formats. Together
  with the main bundle, it brings the selected exact GE input to 161 patches.
- `ge-proton11-6-selection.md` records the selected ranges, the lost upstream
  fullscreen patch, nine newly relevant subjects, exclusions, context adapters,
  and deterministic replay result.
- The GE-Proton11-5 and GE-Proton11-3 bundles and selection records remain as
  the published Beta 2 and Beta 1 provenance. They are not part of Beta 3's
  active replay.
- `wineopenxr-decouple-ge-proton11-3.patch` is the exact
  `patches/wineopenxr/wineopenxr_decouple.patch` retained unchanged because
  its blob remains identical in GE-Proton11-6.

Preparation verifies both annotated upstream tags, their release commits,
the main WineWayland and deliberately excluded child-rendering trees, relevant
blobs, and every bundled GE patch before replay. The `mfmediaengine` sample-pump
repair is already part of the pinned Proton-RTSP `-3` Wine base, not an
additional GE patch.

## Layout adapters and local repair

- `winebus-no-steaminput-ge-proton11-5-rtsp-adapter.patch` preserves
  GE-Proton11-6 main-series `0092` with its seven inserted lines unchanged and
  only its evolved Winebus hunk context adjusted for the RTSP Wine base.
- `wineopenxr-rtsp-makedep-integration.patch` removes one redundant
  `UNIX_LIBS` assignment. RTSP's makedep wrapper must retain its `ntdll.so`
  input while the top-level build supplies OpenXR loader flags.
- `wineopenxr-session-lifetime-ge-proton11-3.patch` is a source-equivalent
  backport of GE-Proton11-3's four-line destroyed-session list cleanup.
- `winewayland-steam-input-ge-proton11-3-rtsp-adapter.patch` carries the
  SetupAPI representation of GE-Proton11-6's exact Steam desktop
  virtual-controller filter source. RTSP's older cfgmgr32 implementation
  forwards the affected enumeration calls into SetupAPI, so importing GE's
  newer standalone cfgmgr32 hunk would duplicate the policy.
- `winewayland-advertise-wine-vr-device-extensions.patch` is the
  project-authored repair introduced for Alpha 4 and retained in Beta 3. It
  makes WineWayland advertise the same
  synthetic `VK_WINE_openvr_device_extensions` and
  `VK_WINE_openxr_device_extensions` capabilities already exposed by Wine's
  X11 path.

The active Wine replay is 160 exact main-series GE patches followed by the exact
DDB cursor repair, the Winebus context adapter, the SetupAPI Steam Input
adapter, and the two-line XR capability repair: 161 exact selected GE patches,
three local follow-ups, and 164 commits total. The final tree is
`b256fa0664b725fdd55ab1f27820c52ea291000d` after a fresh replay on RTSP `-3`
Wine base `a7fcac55ca756e35d5dc0a7c8b70272d9c6a9675`.

The GE video-rework directory is intentionally not imported because this
distribution keeps RTSP's media architecture. Generic selected fixes that
also touch media remain part of the audited Wayland series where they apply
cleanly without replacing that stack. The remaining GE `em-fixups`, unrelated
EAC work, and the separate 58-patch child-rendering subsystem are also excluded;
the latter is kept atomic because it carries SNI and Reflex dependencies.
