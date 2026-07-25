<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Proton-RTSP-Wayland-GE Beta 1 candidate

Run Steam games on native Wayland from the RTSP Proton 11 base with the
released GE-Proton11-3 Wayland work.

## Why you'd want it

- Avoid XWayland scaling blur.
- Use correct fractional scaling and per-monitor refresh rates.
- Use native Wayland clipboard integration, which may improve copy and paste in VRChat.
- Work better with Wayland-first compositors that have limited X11 support.
- Remove an extra display-system hop, which may lower VR latency.

## Current status

Beta 1 is an unpublished release candidate pinned to the exact
`GE-Proton11-3` release. It replays 138 selected GE Wine patches byte-for-byte,
adapts GE's WineWayland controller and WineOpenXR session fixes to the older
RTSP layout, and adds a two-line WineWayland XR capability repair intended to
fix `VK_ERROR_EXTENSION_NOT_PRESENT` on native Wayland.
Its intended release tag is `v11.1.0-beta.1`.

For the Alpha 4 precursor, the deterministic source replay, fresh non-release
build, and artifact gate passed. Its verifier checked all 6,181 files, the
media registry, licenses, launcher policy, filesystem safety, and private-path
leakage. A local 64-bit D3D11 device and one-frame swapchain smoke also passed
under native Wayland.

On 2026-07-25, the Alpha 4 precursor passed VRChat through XRizer 0.5.0 and
WiVRn using Proton's normal XR routing, without the former Vulkan extension
failure. Rendering, tracking, controller mapping, audio, a world transition,
ordinary YouTube playback with seek and pause/resume, a short RTSP check, and
normal shutdown all worked. Its warnings were inherited from unchanged RTSP
components or external software; none implicated the project-authored
WineWayland repair.

Beta 1 removes the no-longer-needed project-specific XR selector and gives the
generated Proton log an unambiguous build identity. The exact 1,465,922,347-byte
artifact passed its build-integrated and standalone verifiers, followed by the
same verifier on the installed copy. Those checks covered all 6,181 regular
files, 238 license and notice files, and 12 media schemes per registry view.

During one VRChat game smoke on 2026-07-25, the log confirmed the Beta 1 build
identity, WineWayland with Winex11 disabled, no `PROTON_XR_MODE`, WineOpenXR
not disabled, XRizer reaching `FOCUSED`, and an orderly
`STOPPING` → `IDLE` → `EXITING` shutdown. It contained no Vulkan-extension
rejection or other `VK_ERROR`, device-loss, or crash signature, and its
warning families matched the Alpha 4 run. Separately, the maintainer confirmed
the expected controller mapping, game and world audio, a world transition, one
YouTube VOD with audio, one seek, one pause/resume, and one short RTSP control.

Direct Windows OpenXR, SteamVR, OpenComposite, broader media, and the default
X11/XWayland path remain untested. Overlapping launches and forced termination
also remain untested. Published Alpha 3 remains the current download.

## Install the published Alpha 3

Download `v11.1.0-alpha.3` from
[GitHub Releases](https://github.com/Go08er/Proton-RTSP-Wayland-GE/releases).
It includes:

- `Proton-RTSP-Wayland-GE-Alpha3.tar.gz`
- `Proton-RTSP-Wayland-GE-Alpha3-source.tar.gz`

There is no Beta 1 release asset yet.

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
4. Open a game's **Properties → Compatibility**, enable the option to force a compatibility tool, and select **Proton RTSP Wayland GE Alpha 3**.

Verify both archives before extraction:

```sh
sha512sum -c Proton-RTSP-Wayland-GE-Alpha3.tar.gz.sha512sum
sha512sum -c Proton-RTSP-Wayland-GE-Alpha3-source.tar.gz.sha512sum
```

Keep the matching source archive with the binary.

### NixOS: published Alpha 3 only

The repository's Nix package intentionally remains pinned to the published
Alpha 3 archive until a verified Beta 1 asset and hash exist:

```nix
inputs.proton-rtsp-wayland-ge.url =
  "github:Go08er/Proton-RTSP-Wayland-GE/291e4562189f337a258ccad2e0abced1df0e76fe";
inputs.proton-rtsp-wayland-ge.inputs.nixpkgs.follows = "nixpkgs";

programs.steam = {
  enable = true;
  extraCompatPackages = [
    inputs.proton-rtsp-wayland-ge.packages.x86_64-linux.default
  ];
};
```

Rebuild NixOS and restart Steam. Nix rejects an archive whose bytes differ
from the pinned Alpha 3 hash.

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

Beta 1 uses Proton's normal XR routing. Do not set `PROTON_XR_MODE`; this
project no longer defines or consumes that variable. The tested VRChat →
XRizer → WiVRn route works without it.

## Known issues and test focus

- Alpha 3's normal route failed on the tested VRChat → XRizer 0.5.0 → WiVRn
  26.6.2 route when DXVK requested Wine's XR Vulkan device extension through
  WineWayland. The Alpha 4 precursor directly advertises that capability and
  passed the same route in game. Other XR routes remain untested.
- GE-Proton11-3 forces Steam Input off under WineWayland and temporarily
  selects the running game's AppID in the host Steam client. The expected
  controller mapping and ordinary exit passed once; overlapping launches and
  forced termination remain untested.
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
The tested local `alpha4` branch remains immutable evidence. Local `beta1`
promotes that GE-Proton11-3 integration and retires the custom XR selector
without changing either earlier branch.
Small upstream contributions remain separate from release assembly; see
[`docs/UPSTREAM-MRS.md`](docs/UPSTREAM-MRS.md).

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
