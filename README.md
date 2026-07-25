<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Proton-RTSP-Wayland-GE Alpha 3 development candidate

This compatibility tool lets Linux players run their Steam library on native Wayland from an RTSP Proton base, avoiding XWayland scaling blur and including a tested `PROTON_XR_MODE=xrizer` OpenVR-to-XRizer path.

## Why you'd want it

- Avoid XWayland scaling blur.
- Use correct fractional scaling.
- Let each monitor use its own refresh rate.
- Remove an extra display-system hop that can lower VR latency.

## Alpha status

Alpha 3 is an unbuilt development candidate. Its 110-patch GE master source
replay is audited, but build, artifact, and game acceptance remain pending.
Alpha 2 remains the tested fallback. Back up important saves and compatdata
prefixes before changing compatibility tools.

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
4. Open a game's **Properties → Compatibility**, enable the option to force a compatibility tool, and select **Proton RTSP Wayland GE Alpha 3**.

When an archive and adjacent checksum are provided, verify them before extraction:

```sh
sha512sum -c Proton-RTSP-Wayland-GE-Alpha3.tar.gz.sha512sum
sha512sum -c Proton-RTSP-Wayland-GE-Alpha3-source.tar.gz.sha512sum
```

Keep the matching source archive with the binary.

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

- The default `auto` mode fails on the tested VRChat / XRizer 0.5.0 / WiVRn route with `VK_ERROR_EXTENSION_NOT_PRESENT` during DXVK device creation. Use `PROTON_XR_MODE=xrizer` for that route.
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
