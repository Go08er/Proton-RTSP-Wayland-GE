<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Proton-RTSP-Wayland-GE Alpha 2

An unofficial, experimental Proton compatibility tool based on the pinned RTSP
Proton 11 source tree. Alpha 2 carries 105 audited Wayland-focused Wine patches
and the current WineOpenXR decoupling repair from a pinned Proton-GE development
snapshot, plus a one-line RTSP build adapter, while preserving RTSP's GStreamer
and media integration.

The name is ordered deliberately: RTSP is the base distribution, while the
`GE` suffix identifies the source of the selected Wayland patch subset. This is
an RTSP-derived build, not a Proton-GE distribution.

This is not an official Valve, Proton-GE, RTSP, XRizer, WiVRn, or Monado release. The name describes its technical provenance; it does not imply affiliation or endorsement.

> [!IMPORTANT]
> Alpha 2 uses Proton-GE commit `9fad3bbe270409e67a8d2f4d123afc73d848306a`,
> selected from `master` on 2026-07-13. It is a pinned development snapshot,
> not GE-Proton11-2 and not a release candidate for publication. Native Wayland
> and XR compatibility should not be assumed for every game, compositor, GPU,
> or XR runtime.

## What this project changes

- Builds Wine with the native Wayland driver for both 64-bit and 32-bit applications.
- Packages the xrandr helper and X11 locale/Compose data used by the Wayland launcher.
- Recognizes `PROTON_USE_WAYLAND=1` and `PROTON_ENABLE_WAYLAND=1` as opt-in native Wayland launch flags.
- Retains the RTSP GStreamer, Media Foundation, and `winegstreamer` integration.
- Applies the current GE WineOpenXR decoupling repair to RTSP's standalone
  WineOpenXR source, followed by a one-line makedep integration fix.
- Remaps Cargo's local checkout root in the bundled Rust AV1 decoder so runtime
  diagnostic strings do not disclose the builder's home directory.
- Adds `PROTON_XR_MODE=xrizer` for an explicit OpenVR-to-XRizer launch path.
- Keeps Proton's normal XR routing when `PROTON_XR_MODE` is absent or set to
  `auto`; no forced DLL disable is added in that mode.

This project does **not** bundle or install XRizer, WiVRn, Monado, SteamVR, or OpenComposite. Install and configure the XR components you intend to use separately.

## Current status

| Area | Alpha 2 status | Scope |
| --- | --- | --- |
| Source composition | Pinned and replay-audited | RTSP base, 105 byte-matched GE Wayland patches, byte-matched WineOpenXR repair, and hash-locked one-line RTSP adapter |
| Build and artifact checks | Passed locally | The staged tool passed source locks, licensing, media routing, metadata, link/permission safety, and a binary-safe privacy scan of 6,181 files |
| Default X11/XWayland path | Runtime test pending | Basic process and non-XR game startup |
| Native Wayland startup | Passed locally | 64-bit and 32-bit command execution used a disposable prefix |
| Native Wayland D3D11 | 64-bit smoke passed | DXVK created a device and presented one frame; a separate new 32-bit probe also aborts on the Alpha 1 control and is not counted as a pass |
| RTSP media playback | Runtime test pending | Artifact and registry checks do not prove playback compatibility |
| OpenVR → XRizer → WiVRn | Runtime test pending | Test `auto` first, then the scoped XRizer fallback |
| Direct Windows OpenXR, SteamVR, and OpenComposite | Runtime test pending | Must remain in `auto` unless a route specifically requires the fallback |

Alpha 1 previously passed 64-bit and 32-bit Wine, native-Wayland D3D11, RTSP
artifact checks, and one roughly eight-minute focused VRChat session through
XRizer 0.5.0 and WiVRn. Those results are useful regression evidence, but they
are not Alpha 2 runtime results and are not a general compatibility claim.

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
4. Open a game's **Properties → Compatibility**, enable the option to force a compatibility tool, and select **Proton RTSP Wayland GE Alpha 2**.

Back up important saves and prefixes before changing compatibility tools. Do not delete an existing compatdata prefix merely as a first troubleshooting step.

When an archive and adjacent checksum are provided, verify them before extraction:

```sh
sha512sum -c Proton-RTSP-Wayland-GE-Alpha2.tar.gz.sha512sum
sha512sum -c Proton-RTSP-Wayland-GE-Alpha2-source.tar.gz.sha512sum
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

Test the normal XR behavior first with a separately installed XR bridge and
runtime:

```text
PROTON_USE_WAYLAND=1 %command%
```

If an OpenVR title specifically needs the tested XRizer fallback:

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

`PROTON_XR_MODE=auto` is the default and preserves Proton's normal behavior,
including its Windows OpenXR bridge. Alpha 2 also applies the pinned GE
WineOpenXR decoupling repair to that bridge. Its effect on this RTSP base still
requires game testing.

`PROTON_XR_MODE=xrizer` is intended only for this route:

```text
Windows OpenVR title → XRizer → native OpenXR runtime
```

In that explicit mode, the launcher disables Proton's `wineopenxr` DLL for the
process. This remains a conservative fallback if the repaired `auto` route
still lets the Windows OpenXR bridge contend with XRizer for the native runtime.

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
- Wayland and WineOpenXR patch reference: [GloriousEggroll/proton-ge-custom](https://github.com/GloriousEggroll/proton-ge-custom), pinned development snapshot
- RTSP Proton commit: `3b4a5f407a5e0cabeef6d3757f29a23f277b429a`
- RTSP Wine base commit: `fd920bd63abb7bf8b52b0f8e40da922ab9e784a4`
- Proton-GE snapshot commit: `9fad3bbe270409e67a8d2f4d123afc73d848306a`
- Snapshot label: `master-2026-07-13` (`development-snapshot`, not GE-Proton11-2)
- DXVK commit: `2cae043bdf767c8a7a2e0ee8d41537acfe773e8e`
- Applied subset: 105 audited Wine commits above the RTSP Wine base
- WineOpenXR repair: `patches/wineopenxr/wineopenxr_decouple.patch` from the
  same pinned Proton-GE snapshot
- WineOpenXR build adapter: one RTSP-specific line removal that preserves the
  makedep wrapper's injected `ntdll.so` while the root build supplies
  `-lopenxr_loader`

The Proton-GE snapshot is used as a patch source and behavior reference.
Proton-GE is not the runtime base of this project, and unrelated GE patch
groups are intentionally excluded. No GitHub publication or release upload is
part of the Alpha 2 preparation workflow. `scripts/build.sh` defaults to
`PACKAGE_RELEASE=0`, so it produces a local game-test directory without release
archives; packaging requires a later explicit opt-in after acceptance.

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
- Wine, the 105 selected GE Wine patches, and the WineOpenXR integration
  modification are LGPL-2.1-or-later. Original patch authorship is retained in
  the bundled format-patch files; see
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
