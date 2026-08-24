<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Architecture

## Source composition

Beta 1 starts from RTSP Proton commit
`3b4a5f407a5e0cabeef6d3757f29a23f277b429a` and its Wine base
`fd920bd63abb7bf8b52b0f8e40da922ab9e784a4`. It imports 138 selected Wine
patches and the exact WineOpenXR decoupling patch from the annotated
`GE-Proton11-3` release at
`8c8003f7f5473d883fbe1bc7ac070c79955754e8`.

Two GE changes need small layout adapters:

- destroyed WineOpenXR sessions are removed from RTSP's standalone session
  list;
- the stale Steam desktop controller is filtered in SetupAPI, which also
  covers RTSP's older cfgmgr32 forwarding path.

The build keeps RTSP's GStreamer media configuration. It does not import GE's
separate video-rework stack.

Native Wayland remains opt-in. Without `PROTON_USE_WAYLAND=1` or its
`PROTON_ENABLE_WAYLAND=1` alias, Proton follows its normal X11/XWayland path.

## XR routing

Beta 1 leaves Proton's normal WineOpenXR routing intact. It does not define or
consume `PROTON_XR_MODE`. Alpha 3 failed on the tested VRChat OpenVR → XRizer
0.5.0 → WiVRn 26.6.2 native-Wayland route: WineOpenXR and XRizer both
initialized, then DXVK device creation returned
`VK_ERROR_EXTENSION_NOT_PRESENT`.

The repair introduced for Alpha 4 addresses the device-creation failure at its
capability boundary:

```text
DXVK / VKD3D-Proton requests VK_WINE_openvr/openxr_device_extensions
                              ↓
WineVulkan asks the active display driver for supported capabilities
                              ↓
WineWayland now advertises both synthetic Wine VR device capabilities
                              ↓
WineVulkan translates them to the native runtime's real requirements
```

Wine's X11 and null drivers already advertise these two Wine-managed
capabilities. The project adds the same two assignments to WineWayland. A
2026-07-25 Alpha 4 VRChat OpenVR → XRizer 0.5.0 → WiVRn test passed with
normal Proton routing and no WineOpenXR override. That validates this route,
not every direct OpenXR, SteamVR, or OpenComposite route.

For an OpenVR application using XRizer only, the low-level diagnostic fallback
is:

```text
WINEDLLOVERRIDES="wineopenxr=d" PROTON_USE_WAYLAND=1 %command%
```

`wineopenxr=d` disables Wine's Windows OpenXR bridge for that process so
XRizer can be the sole Windows-to-host XR bridge. It does not install XRizer
or select a native runtime. It is not an automatic project policy: remove it
after diagnosis and for direct Windows OpenXR applications. SteamVR and
OpenComposite should use their normal route unless a route-specific test
demonstrates otherwise.

## Wayland launcher behavior

When native Wayland is requested and `WAYLAND_DISPLAY` is available, the
launcher:

- selects `winewayland.drv` and disables `winex11.drv`;
- enables Wine's EGL path and disables Proton's fullscreen hack;
- selects a primary output through bundled xrandr, with
  `PROTON_WAYLAND_MONITOR=<output>` as an override;
- points X locale handling at bundled Compose data;
- disables Xalia;
- forces `PROTON_NO_STEAMINPUT=1`;
- asks the host Steam client to use the running game's AppID while it runs,
  then resets that global selection to zero on ordinary exit;
- removes `DISPLAY` from the game environment.

The Steam Input behavior follows GE-Proton11-3. It prevents native-Wayland
windows from falling back to Steam's desktop controller layout. Controller
behavior, overlapping game launches, and forced termination remain runtime
test areas.
