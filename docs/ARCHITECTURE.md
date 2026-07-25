<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Architecture

## Source composition

Alpha 4 starts from RTSP Proton commit
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

`PROTON_XR_MODE=auto` preserves Proton's normal WineOpenXR behavior and is the
first mode to test. Alpha 3 failed on the tested VRChat OpenVR → XRizer 0.5.0
→ WiVRn 26.6.2 native-Wayland route: WineOpenXR and XRizer both initialized,
then DXVK device creation returned `VK_ERROR_EXTENSION_NOT_PRESENT`.

The Alpha 4 repair addresses the device-creation failure at its capability
boundary:

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
capabilities. Alpha 4 adds the same two assignments to WineWayland. This is a
source-level match, not yet proof that every automatic XR route works in game.

For OpenVR through XRizer, the fallback remains:

```text
PROTON_XR_MODE=xrizer PROTON_USE_WAYLAND=1 %command%
```

That mode adds `wineopenxr=d` to the process's final DLL overrides so XRizer
alone owns the native OpenXR runtime. It does not install XRizer, select a
runtime, or change direct Windows OpenXR behavior. Direct Windows OpenXR,
SteamVR, and OpenComposite should remain on `auto` unless their route requires
something else.

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
