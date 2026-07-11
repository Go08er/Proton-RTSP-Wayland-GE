<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Proton-RTSP-11.1-Wayland-GE

An unofficial, experimental Proton compatibility tool based on the RTSP Proton 11 source tree. It carries a curated set of 101 Wayland-focused Wine patches sourced from GE-Proton11-1 while preserving RTSP's GStreamer and media integration.

The name is ordered deliberately: RTSP is the base distribution, while the
`GE` suffix identifies the source of the selected Wayland patch subset. This is
an RTSP-derived build, not a Proton-GE distribution.

This is not an official Valve, Proton-GE, RTSP, XRizer, WiVRn, or Monado release. The name describes its technical provenance; it does not imply affiliation or endorsement.

> [!IMPORTANT]
> Native Wayland and XR support are opt-in. The default launch path remains unchanged. Compatibility has been tested narrowly and should not be assumed for every game, compositor, GPU, or XR runtime.

## What this project changes

- Builds Wine with the native Wayland driver for both 64-bit and 32-bit applications.
- Packages the xrandr helper and X11 locale/Compose data used by the Wayland launcher.
- Recognizes `PROTON_USE_WAYLAND=1` and `PROTON_ENABLE_WAYLAND=1` as opt-in native Wayland launch flags.
- Retains the RTSP GStreamer, Media Foundation, and `winegstreamer` integration.
- Adds `PROTON_XR_MODE=xrizer` for an explicit OpenVR-to-XRizer launch path.
- Leaves Proton's normal XR behavior unchanged when `PROTON_XR_MODE` is absent or set to `auto`.

This project does **not** bundle or install XRizer, WiVRn, Monado, SteamVR, or OpenComposite. Install and configure the XR components you intend to use separately.

## Current status

| Area | Status | Scope |
| --- | --- | --- |
| Default X11/XWayland path | Smoke-tested | Basic Wine process startup |
| Native Wayland, 64-bit and 32-bit | Smoke-tested | `wineboot` and command execution |
| D3D11 under native Wayland | Smoke-tested | Device creation and a window/swapchain test |
| RTSP media payload | Build-verified | 64-bit and 32-bit GStreamer/Wine artifacts and registry routing |
| OpenVR → XRizer → WiVRn | Final candidate tested successfully | VRChat reached a focused XR session under native Wayland and exited cleanly after roughly eight minutes |
| Direct Windows OpenXR in `auto` mode | Not yet tested | Do not use the XRizer mode for this path |
| SteamVR and OpenComposite in `auto` mode | Not yet tested | Default behavior is preserved but not yet validated here |

The successful VR result is one configuration test, not a general compatibility claim.

## Installation

1. Exit Steam completely.
2. Extract the release directory into:

   ```text
   ~/.local/share/Steam/compatibilitytools.d/
   ```

   Create `compatibilitytools.d` if it does not exist. The extracted tool directory should contain `compatibilitytool.vdf` at its top level.

   A common Steam Flatpak location is:

   ```text
   ~/.var/app/com.valvesoftware.Steam/data/Steam/compatibilitytools.d/
   ```
3. Start Steam again.
4. Open a game's **Properties → Compatibility**, enable the option to force a compatibility tool, and select **Proton RTSP 11.1 Wayland (GE patches)**.

Back up important saves and prefixes before changing compatibility tools. Do not delete an existing compatdata prefix merely as a first troubleshooting step.

When an archive and adjacent checksum are provided, verify them before extraction:

```sh
sha512sum -c Proton-RTSP-11.1-Wayland-GE.tar.gz.sha512sum
sha512sum -c Proton-RTSP-11.1-Wayland-GE-source.tar.gz.sha512sum
```

Keep the matching source archive available with the binary. It contains the
prepared source and external snapshots described in [`SOURCE.md`](SOURCE.md).

## Launch options

Use the default Proton/XWayland path:

```text
%command%
```

Opt into native Wayland:

```text
PROTON_USE_WAYLAND=1 %command%
```

Use XRizer with a separately installed native OpenXR runtime:

```text
PROTON_XR_MODE=xrizer PROTON_USE_WAYLAND=1 %command%
```

If automatic primary-output selection is wrong, supply the exact compositor
output name explicitly:

```text
PROTON_WAYLAND_MONITOR=<output-name> PROTON_USE_WAYLAND=1 %command%
```

Capture a compact routing and DLL-load log for one test run:

```text
PROTON_LOG=1 WINEDEBUG=-all,+timestamp,+pid,+tid,+loaddll PROTON_USE_WAYLAND=1 %command%
```

For a compact XRizer diagnostic run:

```text
PROTON_LOG=1 WINEDEBUG=-all,+timestamp,+pid,+tid,+loaddll PROTON_XR_MODE=xrizer PROTON_USE_WAYLAND=1 %command%
```

Use Proton's full Wine exception trace only when the compact log is
insufficient:

```text
PROTON_LOG=1 PROTON_USE_WAYLAND=1 %command%
```

For a full XRizer trace:

```text
PROTON_LOG=1 PROTON_XR_MODE=xrizer PROTON_USE_WAYLAND=1 %command%
```

Environment-variable order before `%command%` is not significant. Disable
`PROTON_LOG` after testing because detailed Wine logs can become large and may
reduce performance. Proton overwrites the same `steam-APPID.log` on the next
logged launch, so preserve a needed log before rerunning.

Repository users can produce a fixed-pattern, path-sanitized summary without
copying the raw log:

```sh
./scripts/summarize-proton-log.sh /path/to/steam-APPID.log
```

The summary is not guaranteed anonymization; inspect it manually before
sharing. For ordinary play, start with the minimal launch options above. This
Wine build selects NTSync automatically when the kernel interface is available,
so `PROTON_USE_NTSYNC=1` is unnecessary. NVAPI follows the base Proton policy;
legacy force-enable or GPU-visibility variables are not required for the tested
route.

## XR mode architecture

`PROTON_XR_MODE=auto` is the default and preserves Proton's normal behavior, including its Windows OpenXR bridge.

`PROTON_XR_MODE=xrizer` is intended only for this route:

```text
Windows OpenVR title → XRizer → native OpenXR runtime
```

In that explicit mode, the launcher disables Proton's `wineopenxr` DLL for the process. This prevents DXVK from initializing Proton's Windows OpenXR bridge in parallel while XRizer is already using the native OpenXR runtime.

The mode is a scoped form of the tested `wineopenxr` override; it does not reproduce Proton 10 wholesale and does not replace an XR runtime. It also does not modify the default mode.

Do not use `PROTON_XR_MODE=xrizer` for a direct Windows OpenXR application. SteamVR, OpenComposite, and other XR arrangements should remain on `auto` unless that exact configuration has been tested.

## Limitations

- Native Wayland support remains experimental and depends on compositor protocol support.
- Some desktop integration, overlays, input methods, window-management behavior, or media paths may differ from XWayland.
- The XRizer mode deliberately disables Proton's Windows OpenXR bridge for that process.
- XRizer and the selected native OpenXR runtime must already work independently of this package.
- Hybrid-GPU and multi-GPU systems may require correct Vulkan adapter selection throughout the game, XRizer, and the native runtime.
- Preserving the RTSP media stack does not guarantee that every codec, site, stream, or game video will work.
- Existing Proton prefixes can retain configuration from earlier tools. Test with backups and change one variable at a time.
- Native Wayland follows the selected GE launcher behavior by disabling Xalia
  and defaulting Steam Input off for that process. `PROTON_NO_STEAMINPUT=0` can
  be used as a controlled compatibility test, but that override is not part of
  the validated XR route.

## Troubleshooting

Start with the smallest launch option that reproduces the issue:

1. Test `%command%` to establish the default-path baseline.
2. Add `PROTON_USE_WAYLAND=1` to isolate the native Wayland path.
3. Add `PROTON_XR_MODE=xrizer` only when the application uses OpenVR through XRizer.
4. Add `PROTON_LOG=1` for a single diagnostic run.

If an XR title fails, record which API the title actually uses—OpenVR or OpenXR—and which runtime is active. A direct OpenXR title failing in `xrizer` mode is expected misuse of the mode, not evidence that the default OpenXR path is broken.

When reporting a problem, include:

- the selected Proton tool version;
- the exact launch options;
- whether XWayland or native Wayland was used;
- the game API: OpenVR, OpenXR, D3D11, D3D12, or Vulkan;
- the XR bridge and native runtime, if applicable;
- whether the problem also occurs in the default `auto` XR mode;
- a minimal, sanitized log excerpt surrounding the first relevant error.

### Sanitize logs before sharing

Proton, Wine, Vulkan, Steam, and OpenXR logs can expose personal or security-sensitive data. Never publish a raw log without reviewing it. Remove or replace:

- user names, host names, and absolute home-directory paths;
- account, profile, session, lobby, or device identifiers;
- IP addresses, local network names, headset serial numbers, and hardware UUIDs;
- authentication tokens, cookies, URLs containing secrets, and full command lines;
- environment variables and registry values unrelated to the report.

Do not upload an entire compatdata prefix, registry export, home directory, or environment dump. Automated redaction is not sufficient by itself; inspect the final file manually.

## Source and build provenance

- Base project: [SpookySkeletons/proton-ge-rtsp](https://github.com/SpookySkeletons/proton-ge-rtsp)
- Wayland patch reference: [GloriousEggroll/proton-ge-custom](https://github.com/GloriousEggroll/proton-ge-custom), GE-Proton11-1
- RTSP Proton commit: `3b4a5f407a5e0cabeef6d3757f29a23f277b429a`
- RTSP Wine base commit: `fd920bd63abb7bf8b52b0f8e40da922ab9e784a4`
- GE-Proton11-1 commit: `fd07a035fadfbe989aef887cb999d0ef236c50d0`
- DXVK commit: `2cae043bdf767c8a7a2e0ee8d41537acfe773e8e`
- Applied subset: 101 audited Wine commits above the RTSP Wine base

The GE-Proton11-1 material is used as a patch source and behavior reference. GE-Proton is not the runtime base of this project, and unrelated GE patch groups are intentionally excluded.

Build orchestration is documented in [`docs/BUILDING.md`](docs/BUILDING.md), the launcher and XR design in [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md), and the deliberately narrow test scope in [`docs/TESTING.md`](docs/TESTING.md). Generated source trees, build products, compatibility prefixes, and private logs are not intended to be committed.

## Acknowledgements

This work builds on Proton, Wine, DXVK, VKD3D-Proton, GStreamer, the RTSP Proton project, and the Wayland work maintained in Proton-GE. XR testing also relies on the independent XRizer, WiVRn, Monado, OpenXR, and OpenVR ecosystems.

Thank you to the maintainers and contributors of those projects. All project names and trademarks belong to their respective owners. This repository is independently assembled and is not affiliated with or endorsed by Valve, CodeWeavers, GloriousEggroll, SpookySkeletons, Khronos, or the XR projects named above.

## Licensing

This is a multi-license repository. No single license covers the complete
Proton distribution.

- Original material created for this repository—including its build and
  verification scripts, documentation, smoke tests, patch-selection manifest,
  and project-authored Proton changes—is BSD-3-Clause; see
  [`LICENSE`](LICENSE).
- Upstream Proton and RTSP top-level material represented by
  [`patches/proton-rtsp-wayland.patch`](patches/proton-rtsp-wayland.patch)
  retains its existing BSD-3-Clause terms and copyright notices; see
  [`LICENSE.proton`](LICENSE.proton) and
  [`LICENSE.upstream-proton`](LICENSE.upstream-proton).
- Wine and the 101 selected GE Wine patches are LGPL-2.1-or-later. Original
  patch authorship is retained in the bundled format-patch files; see
  [`LICENSE.wine`](LICENSE.wine) and
  [`COPYING.LIB.wine`](COPYING.LIB.wine).
- Every other fetched or bundled component remains subject to its own terms.
  See [`NOTICE.md`](NOTICE.md) and the
  [component license map](licenses/COMPONENTS.md).

The project BSD license applies only to original project material. It does not
relicense Proton, Wine, the GE Wine patches, an SDK-derived file, model, font,
or another third-party component.

Binary archives are paired with a complete prepared-source archive and
checksum as described in [`SOURCE.md`](SOURCE.md). Pinned revisions support
source reconstruction and review; the current toolchain is not sufficiently
pinned to promise bit-identical binary reproduction.
