<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Proton-RTSP-Wayland-GE Alpha 3

This compatibility tool lets Linux players run their Steam library on native Wayland from an RTSP Proton base, avoiding XWayland scaling blur and including a tested `PROTON_XR_MODE=xrizer` OpenVR-to-XRizer path.

## Why you'd want it

- Avoid XWayland scaling blur.
- Use correct fractional scaling.
- Let each monitor use its own refresh rate.
- Remove an extra display-system hop, which may lower VR latency.

## Alpha status

Alpha 3's 110-patch GE master source replay has been audited, built, and
artifact-verified. A quick comparison test on July 24 found it performed
comparably to Alpha 2 with no observed regression. The exact packaged release
candidate also passed a focused VRChat smoke test covering native-Wayland
XRizer startup, one world transition, ordinary YouTube playback with one seek
and pause/resume, clean exit, and WiVRn stability. Minimize/restore,
livestreams, and broader XR routes remain untested. Back up important saves and
compatdata prefixes before changing compatibility tools.

## Installation

Download the latest release from
[GitHub Releases](https://github.com/Go08er/Proton-RTSP-Wayland-GE/releases).
Each release includes the binary archive
`Proton-RTSP-Wayland-GE-Alpha3.tar.gz` and the corresponding-source archive
`Proton-RTSP-Wayland-GE-Alpha3-source.tar.gz`. The source archive is provided
to satisfy the LGPL obligations of the bundled Wine components.

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
4. Open a game's **Properties → Compatibility**, enable the option to force a compatibility tool, and select **Proton RTSP Wayland GE Alpha 3**.

Verify the provided checksums before extraction:

```sh
sha512sum -c Proton-RTSP-Wayland-GE-Alpha3.tar.gz.sha512sum
sha512sum -c Proton-RTSP-Wayland-GE-Alpha3-source.tar.gz.sha512sum
```

Keep the matching source archive with the binary.

### NixOS

Add the tag-pinned repository as a flake input:

```nix
inputs.proton-rtsp-wayland-ge.url =
  "github:Go08er/Proton-RTSP-Wayland-GE/v11.1.0-alpha.3";
inputs.proton-rtsp-wayland-ge.inputs.nixpkgs.follows = "nixpkgs";
```

The tagged URL stays on Alpha 3. Omit `/v11.1.0-alpha.3` to follow the default
branch instead.

Then add its default package to `programs.steam.extraCompatPackages`:

```nix
programs.steam = {
  enable = true;
  extraCompatPackages = [
    inputs.proton-rtsp-wayland-ge.packages.x86_64-linux.default
  ];
};
```

Rebuild NixOS and restart Steam. The package is pinned to the exact Alpha 3
release archive by SHA-512; Nix will reject mismatched bytes.

## Launch options

| What you want | What to paste |
| --- | --- |
| Default Proton/XWayland | `%command%` |
| Native Wayland, including direct OpenXR, SteamVR, and OpenComposite | `PROTON_USE_WAYLAND=1 %command%` |
| OpenVR through XRizer and a native OpenXR runtime | `PROTON_XR_MODE=xrizer PROTON_USE_WAYLAND=1 %command%` |
| Select a compositor output | `PROTON_WAYLAND_MONITOR=<output-name> PROTON_USE_WAYLAND=1 %command%` |
| Compact native-Wayland log | `PROTON_LOG=1 WINEDEBUG=-all,+timestamp,+pid,+tid,+loaddll PROTON_USE_WAYLAND=1 %command%` |
| Compact XRizer log | `PROTON_LOG=1 WINEDEBUG=-all,+timestamp,+pid,+tid,+loaddll PROTON_XR_MODE=xrizer PROTON_USE_WAYLAND=1 %command%` |
| Full Wine exception trace | `PROTON_LOG=1 PROTON_USE_WAYLAND=1 %command%` |

`PROTON_ENABLE_WAYLAND=1` remains an alias for `PROTON_USE_WAYLAND=1`. Disable `PROTON_LOG` after testing because detailed Wine logs can become large and reduce performance. This Wine build selects NTSync automatically when the kernel interface is available, so you do not need `PROTON_USE_NTSYNC=1`.

## Known issues

- On the tested VRChat OpenVR → XRizer 0.5.0 → WiVRn 26.6.2 native-Wayland route, Alpha 3 `auto` initialized both XRizer and WineOpenXR before DXVK device creation failed with `VK_ERROR_EXTENSION_NOT_PRESENT`; use `PROTON_XR_MODE=xrizer` for that route.
- Do not use `PROTON_XR_MODE=xrizer` for a direct Windows OpenXR application. Keep SteamVR, OpenComposite, and other XR routes on `auto` unless you have tested that exact setup.
- Native Wayland depends on compositor protocol support. Overlays, input methods, window management, and desktop integration can behave differently from XWayland.
- Native Wayland disables Xalia and defaults Steam Input off for that process. You can try `PROTON_NO_STEAMINPUT=0` as a controlled compatibility test.
- Hybrid-GPU and multi-GPU systems need the correct Vulkan adapter selected throughout the game, XRizer, and native runtime.
- The RTSP media stack does not guarantee that every codec, site, stream, or in-game player will work.

## Troubleshooting

Start with the smallest launch option that reproduces the issue:

1. Test `%command%` to establish the default-path baseline.
2. Add `PROTON_USE_WAYLAND=1` to isolate the native Wayland path.
3. Add `PROTON_XR_MODE=xrizer` only when the application uses OpenVR through XRizer.
4. Add `PROTON_LOG=1` for a single diagnostic run.

Sanitize logs before posting them — see [`docs/REPORTING.md`](docs/REPORTING.md).

## Repository layout

The additive `alpha3` branch preserves RTSP history and is the integration
branch. Reproducible builds and release artifacts come from
`release-engineering/alpha3-a5c30efa`. Future RTSP contributions use separate
topic branches; see [`docs/UPSTREAM-MRS.md`](docs/UPSTREAM-MRS.md).

## Provenance

- RTSP Proton commit: `3b4a5f407a5e0cabeef6d3757f29a23f277b429a`
- RTSP Wine base commit: `fd920bd63abb7bf8b52b0f8e40da922ab9e784a4`
- Proton-GE snapshot commit: `a5c30efa111c6a834395e70da88c801536c68f6d`
- Proton-GE Wine commit: `fc39a66977983a16a31318f98386386ec2dd6b55`
- DXVK commit: `2cae043bdf767c8a7a2e0ee8d41537acfe773e8e`

See [`SOURCE.md`](SOURCE.md) for the complete source and build record.

## Licensing

- Original project material is BSD-3-Clause.
- Upstream Proton and RTSP material keeps its existing BSD-3-Clause terms.
- Wine, the selected GE Wine patches, and other third-party components keep their own licenses.

See [`NOTICE.md`](NOTICE.md) and the [component license map](licenses/COMPONENTS.md).

## Acknowledgements

This work builds on Proton, Wine, DXVK, VKD3D-Proton, GStreamer, the RTSP Proton project, and the Wayland work maintained in Proton-GE. XR testing also relies on XRizer, WiVRn, Monado, OpenXR, and OpenVR.

Thank you to the maintainers and contributors of those projects.

All project names and trademarks belong to their respective owners; this repository is independently assembled and is not affiliated with or endorsed by Valve, CodeWeavers, GloriousEggroll, SpookySkeletons, Khronos, or the XR projects named above.
