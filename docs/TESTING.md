<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Testing

Compatibility claims should be limited to the exact path exercised. Back up important prefixes and change only one variable per comparison.

## D3D11 smoke programs

The two small programs in `tests/` can be built with MinGW-w64. Build both
architectures when the corresponding compilers are available:

```sh
x86_64-w64-mingw32-gcc -O2 -Wall -Wextra \
  -o tests/d3d11-smoke-x86_64.exe tests/d3d11-smoke.c -ld3d11 -ldxgi
x86_64-w64-mingw32-gcc -O2 -Wall -Wextra \
  -o tests/d3d11-swapchain-smoke-x86_64.exe tests/d3d11-swapchain-smoke.c -ld3d11 -ldxgi
i686-w64-mingw32-gcc -O2 -Wall -Wextra \
  -o tests/d3d11-smoke-i686.exe tests/d3d11-smoke.c -ld3d11 -ldxgi
i686-w64-mingw32-gcc -O2 -Wall -Wextra \
  -o tests/d3d11-swapchain-smoke-i686.exe tests/d3d11-swapchain-smoke.c -ld3d11 -ldxgi
```

Run them with the built Alpha 2 game-test directory and a disposable prefix,
never a live game prefix. For example:

```sh
TOOL_DIR=/path/to/Proton-RTSP-Wayland-GE-Alpha2
STEAM_COMPAT_DATA_PATH=/tmp/proton-rtsp-wayland-ge-d3d11-smoke \
  PROTON_USE_WAYLAND=1 \
  "$TOOL_DIR/proton" run "$PWD/tests/d3d11-smoke-x86_64.exe"
STEAM_COMPAT_DATA_PATH=/tmp/proton-rtsp-wayland-ge-d3d11-smoke \
  PROTON_USE_WAYLAND=1 \
  "$TOOL_DIR/proton" run "$PWD/tests/d3d11-swapchain-smoke-x86_64.exe"
```

The device test exits after creating D3D11 successfully. The swapchain test
opens a small window, presents one frame, and exits. Repeat the commands with
the i686 executables to exercise the 32-bit path.

## Alpha 2 game-test checklist

1. Run `scripts/verify.sh` on the built tool.
2. Confirm the default launch path starts without an injected `wineopenxr=d`
   override.
3. Confirm `PROTON_USE_WAYLAND=1` loads `winewayland.drv` and does not load `winex11.drv`.
4. Check that the log has no missing xrandr or Compose-file error.
5. Exercise 64-bit and 32-bit Wine startup.
6. Exercise D3D11 device creation and a window/swapchain under native Wayland.
7. Verify a desktop/non-XR title or mode before adding XR.
8. For an OpenVR title using XRizer, test the default `auto` mode first. Record
   whether the patched WineOpenXR component loads and whether graphics-device
   initialization and XR session creation succeed.
9. If the `auto` route fails in a way consistent with the prior WineOpenXR
   conflict, add `PROTON_XR_MODE=xrizer` and confirm the final DLL overrides
   include `wineopenxr=d`.
10. Confirm the OpenXR session reaches its ready/focused state and shuts down
    cleanly in each route tested.
11. Test direct Windows OpenXR, SteamVR, or OpenComposite only in `auto` unless
    the route's design explicitly requires the fallback.
12. Re-test RTSP and other media playback used by the title; artifact and
    registry checks alone do not validate playback.

## Alpha 2 status

| Path | Status |
| --- | --- |
| Pinned source and active patch-bundle audit | Prepared: RTSP base, 105 GE Wayland patches, exact GE WineOpenXR repair, and one-line RTSP makedep adapter |
| Built-artifact verifier | Passed on the staged Alpha 2 tool: 6,181 regular files plus all links and directories checked |
| Rust AV1 source-path remap | Passed for both `libgstdav1d.so` targets; the complete tool contains no builder-home path |
| Basic Wine startup, 64-bit and 32-bit | Passed under native Wayland with a disposable prefix |
| 64-bit D3D11 device and swapchain under native Wayland | Passed; DXVK loaded the repaired WineOpenXR provider, handled the unavailable runtime, selected NVIDIA, created the device, and presented one frame |
| Additional 32-bit D3D11 diagnostic | Exited 3 during DXVK device creation on both Alpha 2 and the unchanged Alpha 1 control; not attributed to the Alpha 2 patch set and not a pass |
| RTSP/media playback | Runtime test pending; a dead world URL exercised repeated failure cleanup but not successful playback |
| OpenVR → XRizer → WiVRn in `auto` | Failed: DXVK repeatedly returned `VK_ERROR_EXTENSION_NOT_PRESENT` while both XRizer and WineOpenXR used the active runtime |
| OpenVR → XRizer → WiVRn with `PROTON_XR_MODE=xrizer` | Passed: WineOpenXR stayed disabled, XRizer reached `FOCUSED`, WiVRn remained connected for 5 minutes 19 seconds, and the process exited cleanly |
| Direct Windows OpenXR, SteamVR, and OpenComposite | Runtime test pending |
| Broad compositor/GPU coverage | Not claimed |

The local `steam-run` harness emits repeated DRI2 setup warnings because it is
not Steam's complete pressure-vessel runtime. They were present on successful
smokes and are not an Alpha 2 failure signal. The 32-bit D3D11 diagnostic above
is retained as a separate issue: basic 32-bit Wine works, but neither Alpha 2
nor its Alpha 1 control completed that newly added DXVK probe. Do not convert
that comparison into an Alpha 2 regression claim.

The accepted forced-XRizer game run contained no `VK_ERROR`, `DXGI_ERROR`,
`XR_ERROR`, device loss, GPU reset, out-of-memory event, encoder fault, network
fault, or new crash dump. Twelve PipeWire playback overflows and isolated DXVK
shared-image warnings remain monitoring items, not demonstrated Alpha 2
regressions. Repeated GStreamer cleanup assertions coincided with a known dead
world-media URL and also existed in the working Alpha 1 control.

## Alpha 1 regression evidence

The accepted Alpha 1 build passed basic 64-bit and 32-bit Wine startup, D3D11
device and swapchain smoke tests under native Wayland, and RTSP GStreamer
artifact and registry verification. One VRChat run through XRizer 0.5.0 and
WiVRn reached `FOCUSED`, remained focused for roughly eight minutes, exited
cleanly, and recorded exit code 0.

That log did not contain `VK_ERROR`, graphics-device loss, out-of-memory, or
the earlier `InitializeEngineGraphics` failure. It is useful as a regression
baseline only. Alpha 2 independently passed the forced-XRizer route described
above.

## Diagnostic logs

Use `auto` when diagnosing a route that is supposed to retain Proton's Windows
OpenXR bridge:

```text
PROTON_LOG=1 WINEDEBUG=-all,+timestamp,+pid,+tid,+loaddll PROTON_USE_WAYLAND=1 %command%
```

For OpenVR through XRizer and a native OpenXR runtime, use the accepted scoped
route:

```text
PROTON_LOG=1 WINEDEBUG=-all,+timestamp,+pid,+tid,+loaddll PROTON_XR_MODE=xrizer PROTON_USE_WAYLAND=1 %command%
```

Use plain `PROTON_LOG=1` only when the compact log is insufficient, then remove
it for ordinary play. The prior Alpha 1 run produced an 18.2 MB, 198,216-line
full log in under eight minutes; nearly all of it was Wine exception/unwind
trace noise rather than a failure.

The read-only summarizer extracts fixed routing, device, XR lifecycle, and
failure patterns and replaces common home/runtime path prefixes:

```sh
./scripts/summarize-proton-log.sh /path/to/steam-APPID.log
```

It does not modify the input. Its output still requires manual privacy review.
Preserve a needed `steam-APPID.log` before another logged launch overwrites it.

In that prior Alpha 1 log, the NVIDIA GPU was selected on a hybrid system,
NTSync started automatically, `wineopenxr.dll` was not loaded, and XRizer
reached `FOCUSED`. Compare the corresponding Alpha 2 events rather than
assuming the older result carries forward.

Media warnings remain a separate test area. Four apparent missing-decoder
messages named `text/html`, indicating that a web endpoint returned HTML rather
than that an HTML codec should be added. GBM initialization and isolated shared
texture-handle warnings should be investigated only against a reproducible
video, capture, or Spout failure; they did not disrupt that Alpha 1 XR session.

Before sharing a log, remove personal paths, account and session identifiers, network information, command lines, environment values, hardware UUIDs, and unrelated registry content. Never publish an entire compatibility prefix.
