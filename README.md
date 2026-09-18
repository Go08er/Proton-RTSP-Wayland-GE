<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Proton-RTSP-Wayland-GE

Run Steam games on native Wayland from the RTSP Proton 11 base with selected
Proton-GE Wayland work.

Each release pins an exact upstream RTSP Proton release and an exact GE-Proton
release. Those pins are recorded in `NOTICE.md` and `SOURCE.md` on that
release's branch and tag; the current release's records are linked below.

## Why you'd want it

- Avoid XWayland scaling blur.
- Use correct fractional scaling and per-monitor refresh rates.
- Work better with Wayland-first compositors that have limited X11 support.
- Keep Proton's normal XR routing for the VRChat → XRizer → WiVRn route
  tested on earlier releases; Beta 4 has a maintainer-reported smoke pass.

## Releases

The current download is the latest entry on the
[Releases page](https://github.com/Go08er/Proton-RTSP-Wayland-GE/releases).
Every release publishes a binary archive, a corresponding-source archive, and a
`.sha512sum` for each.

Current release: **Beta 4**, combining Proton-RTSP 11-4 with the reviewed
GE-Proton11-7 Wayland selection. Its source recipe and Nix package are also
on `main`; Beta 3 remains available as a fallback.

Per-release detail lives with the release rather than on this page. The links
below target Beta 4; use the matching branch or tag for an older release:

| What | Where |
| --- | --- |
| What changed, and how it was tested | that release's notes on the Releases page |
| Exact pinned upstream revisions | [Beta 4 NOTICE](https://github.com/Go08er/Proton-RTSP-Wayland-GE/blob/beta4/NOTICE.md) |
| Corresponding-source record | [Beta 4 SOURCE](https://github.com/Go08er/Proton-RTSP-Wayland-GE/blob/beta4/SOURCE.md) |
| Gate results and game-test checklists | [Beta 4 testing record](https://github.com/Go08er/Proton-RTSP-Wayland-GE/blob/beta4/docs/TESTING.md) |
| Component licence map | [Beta 4 licence map](https://github.com/Go08er/Proton-RTSP-Wayland-GE/blob/beta4/licenses/COMPONENTS.md) |

Each release states its evidence explicitly and distinguishes machine-checked
gates from maintainer attestation. Read that before relying on a build.

Direct Windows OpenXR, SteamVR, OpenComposite, broader media, and the default
X11/XWayland path are outside the tested route on every release so far.
Overlapping launches and forced termination are also untested. The previous
release stays available as a fallback.

## Install

Download the latest release from the
[Releases page](https://github.com/Go08er/Proton-RTSP-Wayland-GE/releases).
Each release contains, where `<Release>` is that release's name such as
`Beta4`:

- `Proton-RTSP-Wayland-GE-<Release>.tar.gz`
- `Proton-RTSP-Wayland-GE-<Release>-source.tar.gz`
- a `.sha512sum` for each

### Upgrading from Alpha 2 or Alpha 3

Remove `PROTON_XR_MODE=xrizer` from the game's Steam launch options. Beta 1 and
later releases do not define or read this retired selector, so leaving it set is inert and
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
4. Open a game's **Properties → Compatibility**, enable the option to force a compatibility tool, and select the entry matching the release you installed, for example **Proton RTSP Wayland GE Beta 4**.

Verify both archives before extraction (Beta 4 example):

```sh
sha512sum -c Proton-RTSP-Wayland-GE-Beta4.tar.gz.sha512sum
sha512sum -c Proton-RTSP-Wayland-GE-Beta4-source.tar.gz.sha512sum
```

Keep the matching source archive with the binary.

### NixOS

The Nix package extracts a hash-pinned prebuilt archive; it does not compile
Proton. `main` currently installs Beta 4 too, but pin the release tag for a
stable input rather than following a moving branch:

```nix
inputs.proton-rtsp-wayland-ge.url =
  "github:Go08er/Proton-RTSP-Wayland-GE/v11.1.0-beta.4";
inputs.proton-rtsp-wayland-ge.inputs.nixpkgs.follows = "nixpkgs";

programs.steam = {
  enable = true;
  extraCompatPackages = [
    inputs.proton-rtsp-wayland-ge.packages.x86_64-linux.default
  ];
};
```

Rebuild NixOS and restart Steam. Nix rejects an archive whose bytes differ
from the hash pinned in that tag's
[`nix/package.nix`](https://github.com/Go08er/Proton-RTSP-Wayland-GE/blob/v11.1.0-beta.4/nix/package.nix).

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

Beta releases use Proton's normal XR routing. See the
[upgrade note](#upgrading-from-alpha-2-or-alpha-3) if old launch options still
contain the retired selector.

## Known issues and test focus

- Alpha 3's normal route failed on the tested VRChat → XRizer 0.5.0 → WiVRn
  26.6.2 route when DXVK requested Wine's XR Vulkan device extension through
  WineWayland; every release since Alpha 4 carries the repair.
- GE forces Steam Input off under WineWayland and temporarily
  selects the running game's AppID in the host Steam client; the expected
  controller mapping and ordinary exit passed once.
- Native Wayland depends on compositor protocol support. Beta 4 requires
  `wl_output` version 4; older advertised versions will not register outputs.
  Overlays, input methods, and window management can differ from XWayland.
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

`main` contains the published Beta 4 recipe with this project landing page.
Its other tracked files match the `beta4` branch. Use a release tag for a
fixed source snapshot. Each release has its own branch and immutable tag
carrying a release-specific README, `NOTICE.md`, and `SOURCE.md`.
Published branches and tags are never rewritten,
and each release branch builds on the previous one without modifying it.

Small upstream contributions stay on their own `feat/` branches, separate from
release assembly.

### Live feature comparisons

Compare a branch against the upstream RTSP release it is built on, which that
branch's [`NOTICE.md`](NOTICE.md) records:

    https://github.com/SpookySkeletons/Proton-RTSP/compare/<rtsp-tag>...Go08er:Proton-RTSP-Wayland-GE:<branch>

| Ref | Scope | Compare |
| --- | --- | --- |
| `beta4` | RTSP 11-4 with GE-Proton11-7 Wayland selection | [RTSP base → Beta 4](https://github.com/SpookySkeletons/Proton-RTSP/compare/proton-rtsp-11.0-20260609-4...Go08er:Proton-RTSP-Wayland-GE:beta4) |
| `feat/wineopenxr-decouple` | WineOpenXR state decoupling with the RTSP build adapter | [RTSP base → XR decoupling](https://github.com/SpookySkeletons/Proton-RTSP/compare/rtsp-11.0-20260609-1...Go08er:Proton-RTSP-Wayland-GE:feat/wineopenxr-decouple) |
| `feat/wayland-build-wiring` | Proton-side build and launcher wiring only | [RTSP base → Wayland wiring](https://github.com/SpookySkeletons/Proton-RTSP/compare/rtsp-11.0-20260609-1...Go08er:Proton-RTSP-Wayland-GE:feat/wayland-build-wiring) |

For full scope, status, attribution, and contribution details, see
[`docs/UPSTREAM-MRS.md`](docs/UPSTREAM-MRS.md).

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
