<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Architecture

## Source composition

The build starts from the pinned `SpookySkeletons/proton-ge-rtsp` Proton 11 tree. It applies an audited 101-patch Wine Wayland subset from GE-Proton11-1, adds the matching Wayland build dependencies and X11 locale data, and retains the RTSP media/GStreamer configuration.

Native Wayland remains opt-in. Without `PROTON_USE_WAYLAND=1` or `PROTON_ENABLE_WAYLAND=1`, the launcher preserves the normal Proton path.

## XR mode

Default mode keeps Proton's ordinary XR behavior:

```text
PROTON_XR_MODE=auto
```

The explicit XRizer mode is designed for:

```text
Windows OpenVR application
        ↓
Proton OpenVR/vrclient path
        ↓
XRizer
        ↓
native OpenXR runtime such as WiVRn or Monado
```

DXVK normally initializes both OpenVR and OpenXR extension providers. In the tested OpenVR-to-XRizer arrangement, Proton's `wineopenxr` provider attempted to use the same native runtime in parallel and graphics-device creation failed. `PROTON_XR_MODE=xrizer` adds `wineopenxr=d` to the final Wine DLL overrides for that process.

This mode does not install XRizer, choose a native OpenXR runtime, or modify the default mode. A direct Windows OpenXR application should not use it.

## Wayland launcher behavior

When native Wayland is requested and `WAYLAND_DISPLAY` is available, the launcher:

- selects `winewayland.drv` and disables `winex11.drv`;
- enables Wine's EGL path;
- disables the Proton fullscreen hack for that launch;
- uses bundled xrandr output to select a primary monitor when possible;
- accepts `PROTON_WAYLAND_MONITOR=<output-name>` as a manual primary-output override;
- points X locale handling at the bundled Compose data;
- disables Xalia and defaults Steam Input off for the native-Wayland process,
  while allowing a deliberate `PROTON_NO_STEAMINPUT=0` test;
- removes `DISPLAY` from the game environment.
