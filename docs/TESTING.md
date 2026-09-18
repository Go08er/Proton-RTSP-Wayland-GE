<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Testing

Compatibility claims should be limited to the exact path exercised. Back up important prefixes and change only one variable per comparison.

## Published Beta 4 evidence and follow-up checklist

Beta 4 passed build-integrated, standalone, and staged-copy artifact verification.
On 2026-09-17 the maintainer reported a smoke pass and accepted the exact tool
bytes for release; `v11.1.0-beta.4` was published on 2026-09-18. This is
maintainer attestation, without an instrumented Beta 4 log or a completed
route-by-route checklist. It does not establish a media improvement or broad
Wayland/XR qualification. The binary archive preserves the tested tool bytes.

Source replay and prerequisite checks are recorded in
[BETA4_PREPARATION.md](BETA4_PREPARATION.md), with input-gate tests in
`tests/preparation-gates.sh`. Do not reinterpret any historical result below
as a Beta 4 result. Follow-up checks remain: native-Wayland/XR routing,
focus/activation, clipboard, monitor removal and non-US keyboard layouts.
Compare media continuity and
seek/replacement latency with RTSP's new default video queue; initially leave
`WINE_MFME_VIDEO_QUEUE_SIZE` unset. No test or installation is authorized by
this checklist alone.

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

Run them with the exact built candidate under test and a disposable prefix,
never a live game prefix. For Beta 4:

```sh
TOOL_DIR=/path/to/Proton-RTSP-Wayland-GE-Beta4
mkdir -p /tmp/proton-rtsp-wayland-ge-d3d11-smoke
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

## Published Beta 3 evidence and follow-up checklist

Beta 3's source replay, build, and static artifact gates passed. On 2026-09-05
the maintainer reported a quick click/smoke test, described stability as
comparable to the prior build, and authorized publication. This is maintainer
attestation; no instrumented Beta 3 log or completed detailed checklist was
provided. The binary archive preserves the exact tested tool bytes.

Direct Windows OpenXR, SteamVR, OpenComposite, broader media, the default
X11/XWayland path, overlapping launches, and forced termination remain
untested on Beta 3. The following are follow-up checks, not claimed passes:

1. Static gate complete: `scripts/verify.sh` passed on the exact Beta 3 tool.
2. Re-test repeated media startup, pause/resume, seek, source replacement, and
   end-of-stream. Proton-RTSP 11-3 adds anti-starvation sample-pump scheduling
   in `mfmediaengine`; only a runtime test can establish its effect.
3. Re-test the RTSP and ordinary web-media paths used by the title. The RTSP
   source bump and Wine bump make Beta 2's media results historical controls,
   not Beta 3 evidence.
4. Establish `%command%` as the X11/XWayland control, then change only
   `PROTON_USE_WAYLAND=1` and repeat startup, D3D11, fullscreen, text input,
   mouse look, cursor rendering, and window lifecycle checks.
5. On native Wayland, include DDB-backed cursor changes in the cursor check;
   Beta 3 selects GE-Proton11-6's exact DDB cursor patch for the first time.
6. For an OpenVR title using XRizer, keep normal Proton routing and verify
   graphics-device initialization, session focus, input, audio, and clean
   shutdown. Do not infer this route from Beta 2.
7. Verify the game controller uses the game's layout under WineWayland and
   that ordinary exit restores Steam's global input selection.

### Beta 3 source status

| Path | Status |
| --- | --- |
| Source base | Pinned: RTSP `proton-rtsp-11.0-20260609-3`, Proton `f3f25735b3c4e37968c97417ede300bc836a6cd2`, Wine `a7fcac55ca756e35d5dc0a7c8b70272d9c6a9675` |
| Pinned GE source | Annotated `GE-Proton11-6`, peeled `7e88cefffc122ea1584c2156b8d7bae6cf69b2a7` |
| GE selection | Source-locked: 160 exact main WineWayland patches plus GE's exact DDB cursor patch; the 58-patch child-rendering stack, including its SNI and Reflex dependencies, and every other `em-fixups` patch are excluded |
| Wine replay | Source-locked: 161 GE-derived patches plus three local follow-ups, 164 commits, final tree `b256fa0664b725fdd55ab1f27820c52ea291000d` |
| Prefix identity | Prepared as `11.0-104` |
| Build and artifact verification | Passed: the 1,465,937,982-byte artifact cleared build-integrated, standalone, and staged-copy verification covering 6,181 regular files, 238 license/notice files, and 12 media schemes per registry view |
| Runtime and game testing | Maintainer-reported quick click/smoke pass on 2026-09-05; stability comparable to the prior build, without an instrumented log or detailed route qualification |
| Nix package | Pinned to the published Beta 3 archive |

## Published Beta 2 game-test checklist

Beta 2 moves **two** things at once: the RTSP base gains upstream's `mf` fix, and
the GE Wayland set moves from `GE-Proton11-3` to `GE-Proton11-5`. The checklist
is ordered so the reason-to-ship is tested first and the regression-prone changes
are tested deliberately rather than incidentally.

### First: the change Beta 2 exists for

1. Run `scripts/verify.sh` on the built tool.
2. **In-game video players.** Upstream's release note for
   `proton-rtsp-11.0-20260609-2` is *"Fixed assert in mf which broke video
   players."* Exercise the players that previously asserted: load a video world,
   start playback, and let it run past the point where playback previously
   failed. This is the single result that decides whether Beta 2 was worth
   shipping.
3. Re-test RTSP and other media playback used by the title. Artifact, registry,
   and plugin-set checks do not validate playback.
4. Exercise seek, pause/resume, and a second consecutive video without
   restarting the game — the fixed assert was in session rate-change command
   handling, so repeated transport commands are the interesting case.

### Second: the GE-Proton11-5 changes most likely to regress

These are behaviour changes, not fixes, and are the reason to test deliberately
rather than assume parity with Beta 1.

5. **Mouse look and relative pointer.** GE-Proton11-5 *removes* WineWayland's
   pointer relative mode and moves pointer warping to `pSetCursorPos`. Under
   native Wayland, confirm desktop-mode mouse look tracks correctly, does not
   drift or hit an invisible boundary, and that the cursor recentres as expected.
6. **Fullscreen behaviour.** 11-5 treats fullscreen windows as resizeable and
   removes an implicit fullscreen path. Confirm entering and leaving fullscreen,
   and alt-tab, behave as they did on Beta 1.
7. **IME**, if used at all. 11-5 replaces the `SetIMEEnabled` driver call with
   `pEnableIMEContext`. Confirm text entry still works; note that 11-5 gates some
   IME behaviour behind an explicit env toggle.
8. **Window lifecycle under load.** 11-5 carries a broader `winewayland.drv`
   ABBA deadlock fix superseding Beta 1's client-surface deadlock patch. Open and
   close windows, change worlds, and alt-tab repeatedly looking for hangs. A hang
   here is the failure this fix is meant to prevent, so its absence is the
   expected result rather than evidence of improvement.

### Then: the standing Wayland and XR route

9. Confirm the default launch path starts without an injected `wineopenxr=d`
   override.
10. Confirm `PROTON_USE_WAYLAND=1` loads `winewayland.drv` and does not load
    `winex11.drv`.
11. Check that the log has no missing xrandr or Compose-file error.
12. Exercise 64-bit and 32-bit Wine startup, D3D11 device creation, and a
    window/swapchain under native Wayland.
13. For an OpenVR title using XRizer, use normal Proton routing; do not set
    `PROTON_XR_MODE`. Confirm graphics-device initialization and XR session
    creation succeed, the session reaches ready/focused, and shutdown is clean.
14. Under native Wayland, verify the controller uses the game's layout rather
    than Steam's desktop layout, and that ordinary exit restores Steam's global
    input selection. Run one XWayland/non-XR control.
15. Create and destroy more than one XR session, or restart the XR application,
    looking for stale-session or teardown failures.

### If something regresses

Beta 2's commits are deliberately ordered **RTSP pins first, GE second**, so an
RTSP-only build is one checkout away and needs no re-derivation. Bisect that way
before assuming which half is at fault. Beta 1 remains installed as the fallback.

## Published Beta 2 status

Released 2026-08-24 as `v11.1.0-beta.2`.

| Path | Status |
| --- | --- |
| Source base | RTSP `proton-rtsp-11.0-20260609-2`, commit `c3ca33a4ebaf66cdebbac5e5fe432e342e395942`; Wine base `4a5f2736c5baf3d20ea7227b9da511e897ff9a2a`, a 2-commit fast-forward from Beta 1's base touching only `dlls/mf/session.c` and `dlls/ntdll/unix/thread.c`, neither of which any selected GE patch touches |
| Pinned GE source | Annotated `GE-Proton11-5`, tag object `fc27a5029c7b90def3222b8fbaf33b69af973940`, peeled `a2b6daedb7273267359ece9d938d6de8dec596b6` |
| Wayland selection | Passed: 152 files re-derived by patch subject, not by numeric range, because GE renumbered the series; each byte-identical to its blob in the GE tree at the tag |
| Wine replay | Passed: 155 Wine commits above the RTSP Wine base, final tree `d6271f4e2c2f50a2a9bd113807de645ad608e3f8` |
| Build and artifact verification | Passed: the 1,465,929,866-byte artifact cleared build-integrated and standalone verification covering 6,181 regular files, 238 license/notice files, and 12 media schemes per registry view |
| Sustained use | Passed by maintainer attestation. Beta 2 ran as the daily driver for an extended period after 2026-08-17. No defect was attributed to Beta 2; problems encountered in that period were traced to VRChat's own updates. |
| Game smoke log | **Not captured.** Unlike Beta 1, no instrumented game-test log exists for Beta 2, so there is no evidence file behind the sustained-use row and no log-verifiable attribution report. |

The published artifact is byte-identical to the copy that was used throughout
that period: same 1,465,929,866 bytes, same 6,181 files and 1,746 symlinks, same
build epoch `1787013508`. Packaging was done from the same prepared tree that
produced it rather than from a fresh build, because this project does not promise
bit-identical binary reproduction.

## Beta 1 game-test checklist

1. Run `scripts/verify.sh` on the built tool.
2. Confirm the default launch path starts without an injected `wineopenxr=d`
   override.
3. Confirm `PROTON_USE_WAYLAND=1` loads `winewayland.drv` and does not load `winex11.drv`.
4. Check that the log has no missing xrandr or Compose-file error.
5. Exercise 64-bit and 32-bit Wine startup.
6. Exercise D3D11 device creation and a window/swapchain under native Wayland.
7. Verify a desktop/non-XR title or mode before adding XR.
8. For an OpenVR title using XRizer, use normal Proton routing. Do not set
   `PROTON_XR_MODE`; Beta 1 no longer defines or consumes it. Confirm
   graphics-device initialization and XR session creation succeed.
9. Only if that route fails in a way consistent with provider contention, try
   `WINEDLLOVERRIDES="wineopenxr=d"` for one diagnostic launch and confirm the
   final DLL overrides contain `wineopenxr=d`.
10. Confirm the OpenXR session reaches its ready/focused state and shuts down
    cleanly in each route tested.
11. Remove the raw override before testing direct Windows OpenXR, SteamVR, or
    OpenComposite. Disabling WineOpenXR may break those routes.
12. Re-test RTSP and other media playback used by the title; artifact and
    registry checks alone do not validate playback.
13. Create and destroy more than one XR session or restart the XR application;
    look for stale-session or teardown failures.
14. Under native Wayland, verify the controller uses the game's layout rather
    than Steam's desktop layout and that ordinary exit restores Steam's global
    input selection. Also run one XWayland/non-XR control.

## Published Beta 1 status

| Path | Status |
| --- | --- |
| Source base | Exact Alpha 4 source commit `5b2a7e3a`; Alpha 4 branch, artifact, log, and report remain unchanged |
| Pinned GE source and Wine replay | Unchanged: annotated `GE-Proton11-3`, 140 Wine commits, final Wine tree `f795acc107bfff20ee6c9442beb151ed9be4ae84` |
| Launcher policy | Prepared: custom `PROTON_XR_MODE` parser and automatic DLL override removed; normal Proton XR routing remains |
| Prepared Proton lock | Passed after the full replay: `b26992637ebd60c3f67eb8bd8126df4a360d2c9f0774cb659270f38ecf82885a`; the final Wine tree and independent WineOpenXR lock remain unchanged |
| Diagnostic identity | Passed: the wrapper recorded `Proton-RTSP-Wayland-GE-Beta1+proton-rtsp-11.0-20260609-1+GE-Proton11-3` without changing prefix semantics |
| Build and artifact verification | Passed: build-integrated, standalone, and installed-copy verification covered the 1,465,922,347-byte artifact, all 6,181 regular files, 238 license/notice files, and 12 media schemes per registry view; repository `dist/` remained empty |
| Game smoke | Passed 2026-07-25. Log-verifiable: exact Beta 1 identity; WineWayland loaded with Winex11 disabled; no `PROTON_XR_MODE`; WineOpenXR was not disabled; XRizer reached `FOCUSED` and shut down through `STOPPING` → `IDLE` → `EXITING`; no `VK_ERROR`, extension-rejection, device-loss, or crash signature; warning families matched Alpha 4. Maintainer attestation: expected controller mapping, game/world audio, one world transition, one YouTube VOD with audio, one seek, one pause/resume, and one short RTSP control passed. Evidence: log `9b5afbec032999bd6211cff0795b320c47553172dc3502d8b45423eb9b763774`; annotated checklist `af0460593fa9bb0ec7dce63ab34483b03f567789c676d67604f1deb0f68bf73d` |

Promotion does not change the normal XR route that passed in Alpha 4: the
retired selector injected a DLL override only when explicitly set to
`xrizer`. The fresh build, verifier passes, and short no-custom-flag game smoke
have now passed. Beta 1 is published as `v11.1.0-beta.1`.

## Alpha 4 precursor evidence

| Path | Status |
| --- | --- |
| Pinned GE source | Exact annotated `GE-Proton11-3` tag object `1a65daf2708a7c8196f651ef4706a75deb56d7b5`, peeled commit `8c8003f7f5473d883fbe1bc7ac070c79955754e8` |
| Active GE Wayland bundle | Source audit passed: 138 selected files copied byte-for-byte from the release tree |
| Wine replay | Source audit passed: 140 linear commits above the RTSP Wine base, final tree `f795acc107bfff20ee6c9442beb151ed9be4ae84` |
| Build and artifact verification | Passed: fresh non-release build, 238 license/notice files, 12 media schemes per registry view, and 6,181-file filesystem/privacy verification |
| Default X11/XWayland control | Pending |
| 64-bit native Wayland D3D11 | Passed locally: WineWayland loaded with X11 disabled, NVIDIA device creation reached feature level 11.1, and a one-frame mailbox swapchain presented without a Vulkan, DXGI, or device-loss error |
| 32-bit standalone D3D11 diagnostic | Not accepted: both programs returned 3; device creation reached feature level 11.1, while the swapchain log ended with `VK_ERROR_OUT_OF_DEVICE_MEMORY`. The device result matches the historical Alpha 1/2 harness limitation and is not attributed to Alpha 4 without a controlled regression |
| OpenVR → XRizer → WiVRn in `auto` | Passed on 2026-07-25: with no WineOpenXR override, VRChat reached `FOCUSED`, rendered and tracked correctly for about 5 minutes 50 seconds, and exited cleanly with no Vulkan, DXGI, OpenXR, device-loss, or graphics-initialization error |
| Scoped `PROTON_XR_MODE=xrizer` fallback | Pending; Alpha 3 remains the known-good comparison |
| Controller and WineOpenXR lifecycle fixes | Passed for this route: the expected game controller mapping worked, WineOpenXR probed and unloaded before device creation, XRizer owned the application session, and ordinary shutdown reached `EXITING`; forced termination and overlapping launches remain untested |
| RTSP/media playback | Limited pass on 2026-07-25: ordinary YouTube video/audio, one seek, one pause/resume, and a short RTSP playback check worked; broader protocols, formats, livestream duration, and stress coverage remain pending |

The active-runtime log records `XR mode: auto`, no `wineopenxr=d` override,
WineWayland without Winex11, successful NVIDIA device creation, XRizer
`FOCUSED`, and an orderly `STOPPING` → `IDLE` → `EXITING` shutdown. The prior
Alpha 3 automatic route failed with `VK_ERROR_EXTENSION_NOT_PRESENT`; Alpha 4
recorded no `VK_ERROR`.

Its warning profile does not implicate the two-line capability repair. The
unchanged RTSP DXVK emitted 243 image-relocation diagnostics and three
shared-handle warnings; accepted Alpha 3 emitted the same families. Five
GStreamer cleanup assertions exactly match Alpha 3. Two additional
`gst_caps_get_size` assertions appeared during the extra RTSP check, but the
relevant call sites are unchanged from the RTSP Wine base and playback
continued. Treat those as an inherited RTSP media-path watch item unless a
same-stream stock-RTSP control or a visible failure shows otherwise. XRizer
binding warnings and Steam Runtime, launcher, and Discord-bridge messages are
external to this distribution's patch set.

The generated Alpha 4 Proton log header reports the RTSP base version while
the tool path reports Alpha 4. This does not affect execution. Beta 1 records
an unambiguous diagnostic label from the distribution build wrapper without
changing compatibility-prefix semantics.

## Published Alpha 3 historical status

| Path | Status |
| --- | --- |
| Pinned GE source | `a5c30efa111c6a834395e70da88c801536c68f6d`, selected from `master` on 2026-07-24 |
| Active Wayland patch bundle | 110 files copied byte-for-byte from the pinned GE tree |
| Wine replay | Passed: 110 linear commits above the RTSP Wine base, final tree `9be5057739e8c749bd3b438e402bd53cae12a0ce` |
| Build and artifact verification | Passed for the packaged binary and corresponding-source release candidate; a neutral extraction passed the 6,181-file verifier and privacy scan |
| Quick game comparison | Informal pass on 2026-07-24: comparable to Alpha 2, with no observed regression |
| Packaged release-candidate smoke | Passed on 2026-07-24 under `PROTON_XR_MODE=xrizer`: native-Wayland startup, XR rendering/tracking/input/audio, one world transition, ordinary YouTube VOD playback with one seek and pause/resume, normal exit, and WiVRn/headset stability |
| OpenVR → XRizer → WiVRn in `auto` | Failed on Alpha 3: XRizer and WineOpenXR both initialized before DXVK device creation returned `VK_ERROR_EXTENSION_NOT_PRESENT` |
| Broader runtime testing | Pending; minimize/restore, livestreams, the no-XR control, and direct OpenXR/SteamVR/OpenComposite routes were not tested |
| Focused regression | Minimize and restore behavior remains untested even though selected patch `0092` changed |

## Historical Alpha 2 status

These Alpha 2 results are retained as comparison evidence; they are not Alpha
3 acceptance results.

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

## Historical Alpha 1 regression evidence

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

Use normal Proton routing when diagnosing a route that is supposed to retain
Wine's Windows OpenXR bridge:

```text
PROTON_LOG=1 WINEDEBUG=-all,+timestamp,+pid,+tid,+loaddll PROTON_USE_WAYLAND=1 %command%
```

Only if OpenVR through XRizer fails in a way consistent with provider
contention, try this low-level diagnostic fallback:

```text
PROTON_LOG=1 WINEDEBUG=-all,+timestamp,+pid,+tid,+loaddll WINEDLLOVERRIDES="wineopenxr=d" PROTON_USE_WAYLAND=1 %command%
```

This disables WineOpenXR for the entire launch. Remove it after diagnosis and
before testing direct Windows OpenXR. Beta 1 does not parse
`PROTON_XR_MODE`; occurrences later in this document are retained as
historical evidence for older builds.

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

## Historical Alpha 2 accepted runtime baseline

| Area | Alpha 2 status | Scope |
| --- | --- | --- |
| Source composition | Pinned and replay-audited | RTSP base, 105 byte-matched GE Wayland patches, byte-matched WineOpenXR repair, and hash-locked one-line RTSP adapter |
| Build and artifact checks | Passed locally | The staged tool passed source locks, licensing, media routing, metadata, link/permission safety, and a binary-safe privacy scan of 6,181 files |
| Default X11/XWayland path | Runtime test pending | Basic process and non-XR game startup |
| Native Wayland startup | Passed locally | 64-bit and 32-bit command execution used a disposable prefix |
| Native Wayland D3D11 | 64-bit smoke passed | DXVK created a device and presented one frame; a separate new 32-bit probe also aborts on the Alpha 1 control and is not counted as a pass |
| RTSP media playback | Runtime test pending | Artifact and registry checks do not prove playback compatibility; a dead world URL exercised only failure cleanup |
| OpenVR → XRizer → WiVRn in `auto` | Failed locally | Both XRizer and WineOpenXR reached the active runtime; DXVK then failed device creation with `VK_ERROR_EXTENSION_NOT_PRESENT` |
| OpenVR → XRizer → WiVRn with `PROTON_XR_MODE=xrizer` | Passed locally | Reached `FOCUSED`, ran for 5 minutes 19 seconds without reconnecting, and exited cleanly with no Vulkan, DXGI, OpenXR, device-loss, or OOM error |
| Direct Windows OpenXR, SteamVR, and OpenComposite | Runtime test pending | Must remain in `auto` unless a route specifically requires the fallback |
