<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Proton-RTSP-Wayland-GE Beta 2

Run Steam games on native Wayland from the RTSP Proton 11 base with the
released GE-Proton11-5 Wayland work.

## Why you'd want it

- Avoid XWayland scaling blur.
- Use correct fractional scaling and per-monitor refresh rates.
- Work better with Wayland-first compositors that have limited X11 support.
- Run the tested VRChat → XRizer → WiVRn route on native Wayland with
  Proton's normal XR routing and no XR DLL override.

## Current status

**Beta 2 is prepared but not yet published, and its runtime testing is not
complete.** Beta 1 remains the current download until that changes. This section
is finalised only when the Beta 2 game test has actually run; see
[`docs/TESTING.md`](docs/TESTING.md#beta-2-candidate-status) for the live state.

Beta 2 moves two things at once:

- **RTSP base** to `proton-rtsp-11.0-20260609-2`, whose upstream release note is
  *"Fixed assert in mf which broke video players."* This is the reason Beta 2
  exists. The Wine base advances two commits from Beta 1's, a fast-forward
  touching only `dlls/mf/session.c` and `dlls/ntdll/unix/thread.c` — neither
  touched by any selected GE patch.
- **GE Wayland work** from `GE-Proton11-3` to `GE-Proton11-5`, re-derived by
  patch subject because GE renumbered its series. This is mostly upstream
  stability work, including a broader `winewayland.drv` deadlock fix, and it
  carries some behaviour changes: WineWayland's pointer relative mode is removed,
  pointer warping moves to `pSetCursorPos`, and the IME driver call is reworked.

Beta 2 keeps everything Beta 1 established: Proton's normal XR routing with no
custom selector, the WineWayland XR capability repair that fixes
`VK_ERROR_EXTENSION_NOT_PRESENT` on the tested VRChat → XRizer → WiVRn route,
and the RTSP GStreamer media stack as the authoritative media implementation.

### Beta 1, the current download

Beta 1 is a published release pinned to the exact `GE-Proton11-3` release. It
replays 138 selected GE Wine patches byte-for-byte and passed a VRChat game
smoke on 2026-07-25: correct build identity, WineWayland with Winex11 disabled,
XRizer reaching `FOCUSED`, an orderly shutdown, and no `VK_ERROR`, device-loss,
or crash signature. The maintainer separately confirmed controller mapping,
game and world audio, a world transition, one YouTube VOD with audio, a seek, a
pause/resume, and one short RTSP control. Its release tag is `v11.1.0-beta.1`.

Direct Windows OpenXR, SteamVR, OpenComposite, broader media, and the default
X11/XWayland path remain untested on both releases. Overlapping launches and
forced termination also remain untested.

## Install

Beta 1 is the current download. When Beta 2 is published these steps are
identical with `Beta1` replaced by `Beta2` and the tag replaced by
`v11.1.0-beta.2`.

Download `v11.1.0-beta.1` from
[GitHub Releases](https://github.com/Go08er/Proton-RTSP-Wayland-GE/releases).
It includes:

- `Proton-RTSP-Wayland-GE-Beta1.tar.gz`
- `Proton-RTSP-Wayland-GE-Beta1-source.tar.gz`

### Upgrading from Alpha 2 or Alpha 3

Remove `PROTON_XR_MODE=xrizer` from the game's Steam launch options. Neither
Beta 1 nor Beta 2 defines or reads this retired selector, so leaving it set is inert and
does nothing. This is separate from the still-supported advanced
`WINEDLLOVERRIDES="wineopenxr=d"` diagnostic fallback documented in
[Troubleshooting](#troubleshooting).

1. Exit Steam completely.
2. Extract the release directory into:

   ```text
   ~/.local/share/Steam/compatibilitytools.d/
   ```

   Create `compatibilitytools.d` if it does not exist. The extracted tool
   directory should contain `compatibilitytool.vdf` at its top level.

   A common Steam Flatpak location is:

   ```text
   ~/.var/app/com.valvesoftware.Steam/data/Steam/compatibilitytools.d/
   ```
3. Start Steam again.
4. Open a game's **Properties → Compatibility**, enable the option to force a compatibility tool, and select **Proton RTSP Wayland GE Beta 1**.

Verify both archives before extraction:

```sh
sha512sum -c Proton-RTSP-Wayland-GE-Beta1.tar.gz.sha512sum
sha512sum -c Proton-RTSP-Wayland-GE-Beta1-source.tar.gz.sha512sum
```

Keep the matching source archive with the binary.

### NixOS

The repository's Nix package is pinned to the verified Beta 1 archive:

```nix
inputs.proton-rtsp-wayland-ge.url =
  "github:Go08er/Proton-RTSP-Wayland-GE/v11.1.0-beta.1";
inputs.proton-rtsp-wayland-ge.inputs.nixpkgs.follows = "nixpkgs";

programs.steam = {
  enable = true;
  extraCompatPackages = [
    inputs.proton-rtsp-wayland-ge.packages.x86_64-linux.default
  ];
};
```

Rebuild NixOS and restart Steam. Nix rejects an archive whose bytes differ
from the pinned Beta 1 hash.

## Launch options

| What you want | What to paste |
| --- | --- |
| Default Proton/XWayland | `%command%` |
| Native Wayland; test this first | `PROTON_USE_WAYLAND=1 %command%` |
| Select a compositor output | `PROTON_WAYLAND_MONITOR=<output-name> PROTON_USE_WAYLAND=1 %command%` |
| Compact native-Wayland log | `PROTON_LOG=1 WINEDEBUG=-all,+timestamp,+pid,+tid,+loaddll PROTON_USE_WAYLAND=1 %command%` |

`PROTON_ENABLE_WAYLAND=1` remains an alias for
`PROTON_USE_WAYLAND=1`. NTSync is selected automatically when the kernel
interface is available. Disable logging after testing because detailed Wine
logs can become large and reduce performance.

Both betas use Proton's normal XR routing. See the
[upgrade note](#upgrading-from-alpha-2-or-alpha-3) if old launch options still
contain the retired selector.

## Known issues and test focus

- Alpha 3's normal route failed on the tested VRChat → XRizer 0.5.0 → WiVRn
  26.6.2 route when DXVK requested Wine's XR Vulkan device extension through
  WineWayland; Beta 1 and Beta 2 both carry the repair.
- GE forces Steam Input off under WineWayland and temporarily
  selects the running game's AppID in the host Steam client; the expected
  controller mapping and ordinary exit passed once.
- Native Wayland depends on compositor protocol support. Overlays, input
  methods, and window management can differ from XWayland.
- The RTSP media stack does not guarantee every codec, site, stream, or
  in-game player.

## Troubleshooting

1. Test `%command%` to establish the default-path baseline.
2. Add `PROTON_USE_WAYLAND=1` to isolate the native Wayland path.
3. Add `PROTON_LOG=1` for a single diagnostic run.

Advanced XRizer fallback: if an OpenVR application using XRizer still fails
during XR initialization, try:

```text
WINEDLLOVERRIDES="wineopenxr=d" PROTON_USE_WAYLAND=1 %command%
```

`wineopenxr=d` disables Wine's Windows OpenXR bridge for that launch so XRizer
can be the only Windows-to-host XR bridge. It does not install XRizer or select
the host OpenXR runtime. Remove it after troubleshooting and for direct Windows
OpenXR applications; do not treat it as the default for SteamVR or
OpenComposite. Those routes may fail while WineOpenXR is disabled.
If the tested VRChat → XRizer → WiVRn route needs it, report that as a bug.

If launch options already set `WINEDLLOVERRIDES`, add `;wineopenxr=d` inside
the same quoted value instead of defining the variable twice.

Sanitize logs before posting them — see [`docs/REPORTING.md`](docs/REPORTING.md).

## Repository layout and provenance

The public `alpha3` branch and release remain immutable comparison points.
The tested local `alpha4` branch remains immutable evidence. The `beta1` branch
promotes that GE-Proton11-3 integration and retires the custom XR selector
without changing either earlier branch. The `beta2` branch builds on `beta1`
without modifying it, moving the RTSP base forward and re-deriving the GE
Wayland selection against `GE-Proton11-5`.
Small upstream contributions remain separate from release assembly.

### Live feature comparisons

Each comparison uses the RTSP release that branch is built on:
`rtsp-11.0-20260609-2` for `beta2`, `rtsp-11.0-20260609-1` for everything
earlier.

| Ref | Scope | Compare |
| --- | --- | --- |
| `beta2` | Prepared, unpublished: GE-Proton11-5 Wayland set on the newer RTSP base | [RTSP base → Beta 2](https://github.com/SpookySkeletons/Proton-RTSP/compare/rtsp-11.0-20260609-2...Go08er:Proton-RTSP-Wayland-GE:beta2) |
| `beta1` | Complete distribution integration: GE Wine replay, dependencies, packaging, and launcher | [RTSP base → Beta 1](https://github.com/SpookySkeletons/Proton-RTSP/compare/rtsp-11.0-20260609-1...Go08er:Proton-RTSP-Wayland-GE:beta1) |
| `feat/wineopenxr-decouple` | Focused WineOpenXR registry and callback-state decoupling with the RTSP build adapter | [RTSP base → WineOpenXR decoupling](https://github.com/SpookySkeletons/Proton-RTSP/compare/rtsp-11.0-20260609-1...Go08er:Proton-RTSP-Wayland-GE:feat/wineopenxr-decouple) |
| `feat/wayland-build-wiring` | Proton-side build and launcher wiring only | [RTSP base → Wayland wiring](https://github.com/SpookySkeletons/Proton-RTSP/compare/rtsp-11.0-20260609-1...Go08er:Proton-RTSP-Wayland-GE:feat/wayland-build-wiring) |

For full scope, status, attribution, and contribution details, see
[`docs/UPSTREAM-MRS.md`](docs/UPSTREAM-MRS.md).

Beta 2 (prepared):

- RTSP Proton: `c3ca33a4ebaf66cdebbac5e5fe432e342e395942`
- RTSP Wine base: `4a5f2736c5baf3d20ea7227b9da511e897ff9a2a`
- GE-Proton11-5 peeled commit: `a2b6daedb7273267359ece9d938d6de8dec596b6`
- GE-Proton11-5 Wine gitlink: `36078f5f947532885a596dabbc7893c048133660` (provenance only; GE's Wine is never built here)

Beta 1 (published):

- RTSP Proton: `3b4a5f407a5e0cabeef6d3757f29a23f277b429a`
- RTSP Wine base: `fd920bd63abb7bf8b52b0f8e40da922ab9e784a4`
- GE-Proton11-3 peeled commit: `8c8003f7f5473d883fbe1bc7ac070c79955754e8`
- GE-Proton11-3 Wine: `9578fa3613f3379179b576968bc77c8161ab6ea8`
- Final Beta 1 Wine tree: `f795acc107bfff20ee6c9442beb151ed9be4ae84`

See [`SOURCE.md`](SOURCE.md) for the complete source record.

## Licensing

Original project material is BSD-3-Clause. Upstream Proton, Wine, GE patches,
and other components keep their existing licenses. See [`NOTICE.md`](NOTICE.md)
and the [component license map](licenses/COMPONENTS.md).

## Acknowledgements

This work builds on Proton, Wine, DXVK, VKD3D-Proton, GStreamer,
SpookySkeletons' RTSP Proton, and Proton-GE's Wayland work. XR testing relies
on XRizer, WiVRn, Monado, OpenXR, and OpenVR.

All project names and trademarks belong to their respective owners; this
repository is independently assembled and is not affiliated with or endorsed
by those projects.
