<!-- SPDX-License-Identifier: BSD-3-Clause -->

> **Local Beta 4 preparation branch:** see
> [the upstream audit and replay plan](docs/BETA4_PREPARATION.md).
> There is no Beta 4 build yet. The inherited build configuration and Nix
> package still target Beta 3; the release record below remains Beta 3's.

# Proton-RTSP-Wayland-GE Beta 3

This release combines Proton-RTSP 11-3 with the reviewed
GE-Proton11-6 Wayland work. Beta 2 remains available as a fallback.

## Why you'd want it

- Avoid XWayland scaling blur.
- Use correct fractional scaling and per-monitor refresh rates.
- Work better with Wayland-first compositors that have limited X11 support.
- Keep Proton's normal XR routing for the VRChat → XRizer → WiVRn route that
  passed on Beta 2; Beta 3 has a maintainer-reported quick smoke pass.

## Current status

**Beta 3 is published as `v11.1.0-beta.3`.** It moves two source inputs
forward from the published Beta 2 release:

- **RTSP base** to `proton-rtsp-11.0-20260609-3` at `f3f25735`, with Wine at
  `a7fcac55`. This upstream source adds anti-starvation sample-pump scheduling
  in `mfmediaengine`; it has not yet established any runtime improvement here.
- **GE source** to `GE-Proton11-6` at `7e88ceff`. The release replays 160
  exact main WineWayland selections plus GE's exact DDB cursor patch. The
  58-patch child-rendering stack, including its SNI and Reflex dependencies,
  and every other `em-fixups` patch are intentionally excluded.

Those 161 GE-derived patches plus three local follow-ups produce 164 Wine
commits above the RTSP Wine base and tree
`b256fa0664b725fdd55ab1f27820c52ea291000d`. Beta 3 uses prefix identity
`11.0-104`. The 1,465,937,982-byte tool passed build-integrated,
standalone, and staged-copy verification. On 2026-09-05 the maintainer
reported a quick click/smoke test and stability comparable to the prior build,
and accepted these exact tool bytes for release. This is maintainer
attestation, without an instrumented Beta 3 log or a completed route-by-route
checklist. It does not establish a media improvement or broad qualification.

### Published Beta 2 record

Beta 2 remains available separately. It replays 152 selected GE Wine patches
byte-for-byte and locks 155 Wine commits above its RTSP Wine base. The exact
1,465,929,866-byte artifact passed its build-integrated and standalone
verifiers, covering all 6,181 regular files, 238 license and notice files, and
12 media schemes per registry view.

It then ran as the maintainer's daily driver for an extended period. No defect
was attributed to Beta 2: the problems encountered during that period were
traced to VRChat's own updates rather than to this build. That is **maintainer
attestation from sustained real-world use, not an instrumented test run** — no
game-test log was captured for Beta 2, so there is no evidence file behind this
paragraph, unlike Beta 1's smoke test.

Beta 2 kept everything Beta 1 established: Proton's normal XR routing with no
custom selector, the WineWayland XR capability repair that fixes
`VK_ERROR_EXTENSION_NOT_PRESENT` on the tested VRChat → XRizer → WiVRn route,
and the RTSP GStreamer media stack as the authoritative media implementation.

For Beta 2, direct Windows OpenXR, SteamVR, OpenComposite, broader media, and
the default X11/XWayland path remain untested. Overlapping launches and forced
termination also remain untested. Beta 1 remains available as a fallback.
These detailed Beta 2 runtime results are historical controls, not Beta 3 results.

## Install

Install `v11.1.0-beta.3` from
[GitHub Releases](https://github.com/Go08er/Proton-RTSP-Wayland-GE/releases/tag/v11.1.0-beta.3).
It includes:

- `Proton-RTSP-Wayland-GE-Beta3.tar.gz`
- `Proton-RTSP-Wayland-GE-Beta3-source.tar.gz`

### Upgrading from Alpha 2 or Alpha 3

Remove `PROTON_XR_MODE=xrizer` from the game's Steam launch options. Beta 1,
Beta 2, and Beta 3 do not define or read this retired selector.
Leaving it set is inert and does nothing. This is separate from the supported
advanced `WINEDLLOVERRIDES="wineopenxr=d"` diagnostic fallback documented in
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
4. Open a game's **Properties → Compatibility**, enable the option to force a compatibility tool, and select **Proton RTSP Wayland GE Beta 3**.

Verify both archives before extraction:

```sh
sha512sum -c Proton-RTSP-Wayland-GE-Beta3.tar.gz.sha512sum
sha512sum -c Proton-RTSP-Wayland-GE-Beta3-source.tar.gz.sha512sum
```

Keep the matching source archive with the binary.

### NixOS

The repository's Nix package extracts the verified, hash-pinned Beta 3
archive; it does not compile Proton:

```nix
inputs.proton-rtsp-wayland-ge.url =
  "github:Go08er/Proton-RTSP-Wayland-GE/v11.1.0-beta.3";
inputs.proton-rtsp-wayland-ge.inputs.nixpkgs.follows = "nixpkgs";

programs.steam = {
  enable = true;
  extraCompatPackages = [
    inputs.proton-rtsp-wayland-ge.packages.x86_64-linux.default
  ];
};
```

Rebuild NixOS and restart Steam. Nix rejects an archive whose bytes differ
from the pinned Beta 3 hash.

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

Beta 1, Beta 2, and Beta 3 use Proton's normal XR routing. See the
[upgrade note](#upgrading-from-alpha-2-or-alpha-3) if old launch options still
contain the retired selector.

## Known issues and test focus

- Alpha 3's normal route failed on the tested VRChat → XRizer 0.5.0 → WiVRn
  26.6.2 route when DXVK requested Wine's XR Vulkan device extension through
  WineWayland; Beta 1 and Beta 2 both carry the repair. Beta 3's source replay
  retains it; its quick smoke report does not separately qualify XR routing.
- Beta 2 forces Steam Input off under WineWayland and temporarily selects the
  running game's AppID in the host Steam client; the expected controller
  mapping and ordinary exit passed once. Beta 3 retains that source policy but
  has no separate controller/lifecycle test record.
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
The published `beta3` branch leaves Beta 2 unchanged and integrates the newer
RTSP and GE sources.
Small upstream contributions remain separate from release assembly.

### Live feature comparisons

Each comparison uses the RTSP release that branch is built on:
`proton-rtsp-11.0-20260609-3` for `beta3`, `rtsp-11.0-20260609-2` for
`beta2`, and `rtsp-11.0-20260609-1` for everything earlier.

| Ref | Scope | Compare |
| --- | --- | --- |
| `beta3` | Current release: RTSP 11-3 with GE-Proton11-6 Wayland selection | [RTSP base → Beta 3](https://github.com/SpookySkeletons/Proton-RTSP/compare/proton-rtsp-11.0-20260609-3...Go08er:Proton-RTSP-Wayland-GE:beta3) |
| `beta2` | Previous release: GE-Proton11-5 Wayland selection | [RTSP base → Beta 2](https://github.com/SpookySkeletons/Proton-RTSP/compare/rtsp-11.0-20260609-2...Go08er:Proton-RTSP-Wayland-GE:beta2) |
| `beta1` | Complete distribution integration: GE Wine replay, dependencies, packaging, and launcher | [RTSP base → Beta 1](https://github.com/SpookySkeletons/Proton-RTSP/compare/rtsp-11.0-20260609-1...Go08er:Proton-RTSP-Wayland-GE:beta1) |
| `feat/wineopenxr-decouple` | Focused WineOpenXR registry and callback-state decoupling with the RTSP build adapter | [RTSP base → WineOpenXR decoupling](https://github.com/SpookySkeletons/Proton-RTSP/compare/rtsp-11.0-20260609-1...Go08er:Proton-RTSP-Wayland-GE:feat/wineopenxr-decouple) |
| `feat/wayland-build-wiring` | Proton-side build and launcher wiring only | [RTSP base → Wayland wiring](https://github.com/SpookySkeletons/Proton-RTSP/compare/rtsp-11.0-20260609-1...Go08er:Proton-RTSP-Wayland-GE:feat/wayland-build-wiring) |

For full scope, status, attribution, and contribution details, see
[`docs/UPSTREAM-MRS.md`](docs/UPSTREAM-MRS.md).

Beta 3 (published current release):

- RTSP Proton: `f3f25735b3c4e37968c97417ede300bc836a6cd2`
- RTSP Wine base: `a7fcac55ca756e35d5dc0a7c8b70272d9c6a9675`
- GE-Proton11-6 peeled commit: `7e88cefffc122ea1584c2156b8d7bae6cf69b2a7`
- GE-Proton11-6 Wine gitlink: `9358696fe9a2261329f4a83aa6a65fd436106154` (provenance only; GE's Wine is never built here)
- Final Beta 3 Wine tree: `b256fa0664b725fdd55ab1f27820c52ea291000d`

Beta 2 (published previous release):

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
