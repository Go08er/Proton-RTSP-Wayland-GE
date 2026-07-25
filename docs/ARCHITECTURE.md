<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Architecture

## Source composition

The build starts from the pinned `SpookySkeletons/proton-ge-rtsp` Proton 11
tree. Alpha 3 applies an audited 110-patch Wine Wayland subset plus the current
WineOpenXR decoupling repair from Proton-GE development snapshot
`a5c30efa111c6a834395e70da88c801536c68f6d`. It adds the matching Wayland build
dependencies and X11 locale data while retaining the RTSP media/GStreamer
configuration. The GE snapshot was selected from `master` on 2026-07-24; it is
not GE-Proton11-2.

Native Wayland remains opt-in. Without `PROTON_USE_WAYLAND=1` or `PROTON_ENABLE_WAYLAND=1`, the launcher preserves the normal Proton path.

## XR mode

Default mode keeps Proton's ordinary XR behavior:

```text
PROTON_XR_MODE=auto
```

In Alpha 3, the default path includes the pinned GE WineOpenXR repair applied
to RTSP's standalone `wineopenxr` source. Upstream names the exact input
`wineopenxr_decouple.patch`; its behavior on this RTSP base is not considered
validated until the Alpha 3 game matrix passes.

The GE patch is retained byte-for-byte. A separate one-line RTSP integration
patch removes its redundant `UNIX_LIBS=-lopenxr_loader` assignment because
RTSP's makedep wrapper injects the required `ntdll.so` there. The RTSP root
Makefile already passes `-lopenxr_loader`; retaining both assignments would
replace the injected Wine library and leave Wine debug/NT symbols unresolved.

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

DXVK normally initializes both OpenVR and OpenXR extension providers. In the
prior Alpha 1 OpenVR-to-XRizer test, Proton's `wineopenxr` provider attempted
to use the same native runtime in parallel and graphics-device creation failed.
`PROTON_XR_MODE=xrizer` adds `wineopenxr=d` to the final Wine DLL overrides for
that process. It remains an explicit fallback while Alpha 3's repaired `auto`
route is tested; earlier results do not establish Alpha 3 behavior.

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
