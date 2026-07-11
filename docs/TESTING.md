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

Run them with the release candidate and a disposable prefix, never a live game
prefix. For example:

```sh
TOOL_DIR=/path/to/Proton-RTSP-11.1-Wayland-GE
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

## Release-candidate checklist

1. Run `scripts/verify.sh` on the built tool.
2. Confirm the default launch path starts without an injected `wineopenxr=d` override.
3. Confirm `PROTON_USE_WAYLAND=1` loads `winewayland.drv` and does not load `winex11.drv`.
4. Check that the log has no missing xrandr or Compose-file error.
5. Exercise 64-bit and 32-bit Wine startup.
6. Exercise D3D11 device creation and a window/swapchain under native Wayland.
7. Verify a desktop/non-XR title or mode before adding XR.
8. For an OpenVR title using XRizer, add `PROTON_XR_MODE=xrizer` and confirm the final DLL overrides include `wineopenxr=d`.
9. Confirm the OpenXR session reaches its ready/focused state and shuts down cleanly.
10. Re-test media playback if the title uses network streams or in-world video.

## Current matrix

| Path | Status |
| --- | --- |
| Basic Wine startup, 64-bit and 32-bit | Passed |
| D3D11 device and swapchain under native Wayland | Passed |
| RTSP GStreamer artifact and registry verification | Passed |
| Final-candidate OpenVR → XRizer 0.5.0 → WiVRn VRChat session | Passed; focused for roughly eight minutes and exited cleanly |
| Direct Windows OpenXR in default mode | Not yet documented |
| SteamVR and OpenComposite | Not yet documented |
| Broad compositor/GPU coverage | Not claimed |

## Diagnostic logs

Use a compact log for ordinary routing and DLL-load diagnosis:

```text
PROTON_LOG=1 WINEDEBUG=-all,+timestamp,+pid,+tid,+loaddll PROTON_XR_MODE=xrizer PROTON_USE_WAYLAND=1 %command%
```

Use plain `PROTON_LOG=1` only when the compact log is insufficient, then remove
it for ordinary play. The successful final-candidate run produced an 18.2 MB,
198,216-line full log in under eight minutes; nearly all of it was Wine
exception/unwind trace noise rather than a failure.

The read-only summarizer extracts fixed routing, device, XR lifecycle, and
failure patterns and replaces common home/runtime path prefixes:

```sh
./scripts/summarize-proton-log.sh /path/to/steam-APPID.log
```

It does not modify the input. Its output still requires manual privacy review.
Preserve a needed `steam-APPID.log` before another logged launch overwrites it.

In the successful final-candidate log, the NVIDIA GPU was selected on a hybrid
system, NTSync started automatically, `wineopenxr.dll` was not loaded, XRizer
reached `FOCUSED`, and Steam recorded exit code 0. The log did not contain
`VK_ERROR`, graphics-device loss, out-of-memory, or the earlier
`InitializeEngineGraphics` failure.

Media warnings remain a separate test area. Four apparent missing-decoder
messages named `text/html`, indicating that a web endpoint returned HTML rather
than that an HTML codec should be added. GBM initialization and isolated shared
texture-handle warnings should be investigated only against a reproducible
video, capture, or Spout failure; they did not disrupt this XR session.

Before sharing a log, remove personal paths, account and session identifiers, network information, command lines, environment values, hardware UUIDs, and unrelated registry content. Never publish an entire compatibility prefix.
