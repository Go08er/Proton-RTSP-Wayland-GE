# Upstream contribution map

The published additive `alpha3` branch is an integration and release branch,
not a pull request branch. The entries below preserve its existing topic refs.
Future contributions to `SpookySkeletons/proton-ge-rtsp`
should be opened from the smallest applicable topic branch against RTSP commit
`3b4a5f407a5e0cabeef6d3757f29a23f277b429a`
(`rtsp-11.0-20260609-1`).

Beta 1 is also an integration branch, not a pull request branch. Its new work
has not been proposed upstream:

- the two-line WineWayland OpenVR/OpenXR capability mapping is already a
  standalone format patch and is the cleanest candidate for a focused Wine or
  RTSP review after runtime proof;
- the SetupAPI controller filter adapts GE-Proton11-3 to RTSP's older cfgmgr32
  forwarding layout and should retain GE attribution;
- the WineOpenXR destroyed-session cleanup is a source-equivalent GE backport.

Do not bundle those three changes with the 138-patch GE release replay in a
single upstream request.

## Retired historical topic — Explicit XRizer launcher mode

- **Branch:** `feat/xr-mode-launcher`
- **Commit:** `6c7eee9ce22cdb7cae54e374630c0e9322ce9274`
- **Subject:** `proton: Add an explicit XRizer mode`
- **Diff:** one file, 14 added lines
- **Depends on:** nothing
- **Attribution:** project maintainer
- **Status:** retained as Alpha 3 history; do not propose or merge

XRizer implements the Windows OpenVR API over the host OpenXR runtime.
The selector was useful while diagnosing the older native-Wayland graphics
failure, but Alpha 4 passed the same VRChat → XRizer 0.5.0 → WiVRn 26.6.2
route with normal Proton routing after the WineWayland capability repair.
Beta 1 therefore removes the selector from both the integrated launcher and
the future contribution plan. A user can still apply Wine's raw
`wineopenxr=d` DLL override for a one-off XRizer diagnostic without adding a
project-specific Proton interface.

## Ready topic — WineOpenXR state decoupling

- **Branch:** `feat/wineopenxr-decouple`
- **Commit:** `52b017cc7a2791bee38bc99b1e3e45f697cf1a1b`
- **Subject:** `wineopenxr: Decouple XR and VR registry state`
- **Diff:** four files, 351 additions and 20 deletions
- **Depends on:** nothing
- **Attribution:** Proton-GE commit
  `20ce609c432d3cc5e6c6051680ee1a75e0930782`, carried from snapshot
  `a5c30efa111c6a834395e70da88c801536c68f6d`, plus the RTSP build adapter

This topic keeps the OpenXR registry cache and Vulkan callback state
independent from vrclient's OpenVR path. It is intentionally presented as a
Proton-GE backport rather than as project-authored WineOpenXR work.

The original GE patch adds a direct `-lopenxr_loader` assignment. RTSP's
makedep wrapper already supplies the loader together with its required
`ntdll.so` input, so the topic omits that redundant assignment.

## Draft topic — Native Wayland build and launcher wiring

- **Branch:** `feat/wayland-build-wiring`
- **Commit:** `a4c87c8b1a57a85876775f6b06bb941a187e9b77`
- **Subject:** `proton: Enable native Wayland sessions`
- **Diff:** `.gitmodules`, `Makefile.in`, and `proton`, 182 additions and one
  deletion
- **Status:** local draft; do not open a pull request yet

The draft contains the Wayland build rules, launcher behavior, and repository
declarations for libxml2, libxkbcommon, and Wayland Protocols. Those
dependencies are inherent to the feature and must not be hidden from the
upstream diff.

The current commit declares those submodules but does not add their pinned
gitlinks. It also expects X11 locale data and Wine-side Wayland work that are
not present in the topic. The copied `libxkbcommon-1.7.0` branch hint is stale
relative to the pinned GE 1.9.2 source and must be removed or corrected.

Before proposing native Wayland upstream, agree with the RTSP maintainer on
the source layout. The clean series is a source-prerequisite commit with
matching gitlinks and locale data (or an accepted pinned-fetch alternative),
a separate RTSP-Wine Wayland change with its Wine gitlink update, and finally
the Makefile and launcher wiring. Verify the complete series from a recursive
clone. Its cover note should call out the new dependencies and offer to adapt
their source layout to the maintainer's preference.

## Local-only branches

- `local/piper-phonemize-pin` retains the immutable Piper dependency pin. Its
  referenced Piper commit is unavailable from the upstream object inventory,
  so it is not a viable RTSP pull request.
- `local/distribution-wiring` contains reproducible build inputs and release
  machinery specific to this distribution.

The following also remain integration-only:

- the published Alpha 3 110-patch GE bundle, tested Alpha 4 precursor, and
  Beta 1 138-patch GE release replay;
- distribution release naming and metadata;
- archive verification, privacy scanning, and corresponding-source packaging;
- Nix packaging;
- local job budgeting and diagnostics.

Never use `git push --all`. Push only the specific topic ref intended for
review, and never push a `local/*` branch.
