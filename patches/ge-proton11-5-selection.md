<!-- SPDX-License-Identifier: BSD-3-Clause -->

# GE-Proton11-5 Wayland selection

Beta 2 applies 152 exact files from
`patches/wine-hotfixes/wine-wayland/` at annotated release
`GE-Proton11-5`, peeled commit
`a2b6daedb7273267359ece9d938d6de8dec596b6`.

```text
0002-0007
0009-0034
0045-0050
0078-0081
0084-0091
0093-0101
0110-0124
0126-0130
0134-0143
0145
0151
0166
0173-0177
0179-0180
0182
0184-0208
0211-0213
0221-0224
0236-0242
0247-0256
0265-0266
0268-winewayland-Move-pointer-warp-implementation-to-pSet
```

The 115 upstream files not present byte-for-byte in the bundle comprise:

- 46 AMD/ATI/FSR-specific patches;
- 43 ntoskrnl/WDF/kernel-driver patches;
- 12 unrelated ntdll patches;
- three game-specific `wine.inf` workarounds;
- seven WindowsCodecs patches;
- one metadata/test-only patch;
- two unrelated kernel32/WinTrust patches; and
- upstream `0092`, represented by the context-only local adapter described
  below.

The selected set retains generic WineWayland display, input, lifecycle,
colorspace, OpenGL, and integration work. It also retains generic media fixes
`0207` and `0208` for absolute byte-stream seeking and empty-origin URL
handling. GE's separate video-rework patch directory remains excluded because
RTSP's GStreamer media stack is authoritative.

## Vanished Beta 1 selections

Five subjects selected for Beta 1 no longer exist in GE-Proton11-5.

| Beta 1 selection | Disposition in Beta 2 |
| --- | --- |
| `0035-win32u-Add-SetIMEEnabled-driver-call` | Dropped; selected `0254` introduces the replacement `pEnableIMEContext` driver call. |
| `0036-winewayland-Implement-SetIMEEnabled-driver-call` | Dropped; selected `0255` implements the replacement `pEnableIMEContext` call in WineWayland. |
| `0038-win32u-Call-SetIMEEnabled-from-NtUserAssociateInputC` | Dropped; selected `0254`-`0256` carry the replacement IME-enable mechanism and its WineWayland policy. |
| `0142-winewayland-Don-t-post-IME-update-on-leave-unless-te` | Dropped as superseded by the selected `pEnableIMEContext` series (`0254`-`0256`). |
| `0205-winewayland-Avoid-deadlocks-with-update_client_surfa` | Dropped; selected `0236` is the successor ABBA-deadlock fix for `win_data_mutex` and `user_mutex`. |

## GE-Proton11-5 additions

GE-Proton11-5 contains 36 subjects added after the GE-Proton11-3 series. The
20 generic WineWayland/input additions are included; the 16 AMD/ATI, unrelated
ntdll, kernel32, and WinTrust additions remain outside the established scope.

| GE-Proton11-5 subject | Decision | Reason |
| --- | --- | --- |
| `0234-amdxc-Implement-IAmdExtD3DCreateDevice` | Exclude | AMD extension implementation is outside the generic WineWayland scope. |
| `0235-d3dkmt-Implement-KMTQAITYPE_UMDRIVERNAME` | Exclude | AMD/native-driver identity support is outside the generic selection. |
| `0236-winewayland.drv-Avoid-ABBA-deadlocks-between-win_dat` | Include | Generic WineWayland lock-order fix and successor to the vanished Beta 1 deadlock patch. |
| `0237-winewayland-Remove-now-unnecessary-implicit-fullscre` | Include | Generic fullscreen lifecycle cleanup. |
| `0238-win32u-Enable-fullscreen-clipping-even-if-not-alread` | Include | Required generic fullscreen clipping behavior. |
| `0239-winebus-Support-PROTON_SPOOF_STEAMINPUT_VIDPID-for-S` | Include | Generic Steam Input compatibility for the selected Wayland input path. |
| `0240-winewayland-Skip-no-op-axis_value120-axis_discrete-e` | Include | Generic pointer-axis event correctness. |
| `0241-winewayland-Remove-pointer-relative-mode` | Include | Generic WineWayland pointer-state cleanup. |
| `0242-winewayland-Remove-output_info-structure` | Include | Generic output lifecycle cleanup used by the carried series. |
| `0243-atiadlxx-Implement-ADL_Overdrive_Caps` | Exclude | ATI/ADL hardware support is outside the generic selection. |
| `0244-atiadlxx-Add-stub-for-ADL2_Adapter_Primary_Get` | Exclude | ATI/ADL hardware stub is outside the generic selection. |
| `0245-atiadlxx-Add-stub-for-ADL2_ApplicationProfiles_HitLi` | Exclude | ATI/ADL application-profile support is outside the generic selection. |
| `0246-atiadlxx-Implement-ADL2_Display_Modes_Get` | Exclude | ATI/ADL display-mode support is outside the generic selection. |
| `0247-win32u-Use-the-window-rect-if-the-client-rect-beyond` | Include | Generic window visibility and placement correction. |
| `0248-win32u-Ignore-EGL-device-if-context-cannot-be-create` | Include | Generic EGL device validation for the display path. |
| `0249-imm-Fix-NotifyIME-trace` | Include | Generic IME correctness/diagnostic fix accompanying the selected IME path. |
| `0250-winewayland-Treat-fullscreen-windows-as-resizeable` | Include | Generic fullscreen state behavior. |
| `0251-winewayland-Fix-formatting-of-WAYLAND_SetWindowIcons` | Include | Carries the upstream WineWayland icon-path cleanup verbatim. |
| `0252-winewayland-Fix-TRACE-in-WAYLAND_GetWindowStateUpdat` | Include | Generic WineWayland state diagnostic correction. |
| `0253-win32u-Fix-off-by-one-in-kbd_tables_init_vsc2vk` | Include | Generic keyboard mapping correctness. |
| `0254-win32u-Introduce-pEnableIMEContext-driver-call` | Include | Replacement driver interface for the vanished IME selections. |
| `0255-winewayland-Implement-support-for-pEnableIMEContext` | Include | WineWayland implementation of the replacement IME interface. |
| `0256-HACK-winewayland-Add-env-to-enable-IME` | Include | Completes the selected replacement IME policy. |
| `0257-Revert-ntdll-Also-trap-syscalls-in-the-top-down-rese` | Exclude | Unrelated ntdll syscall-dispatch change. |
| `0258-Revert-ntdll-Support-x86_64-syscall-emulation` | Exclude | Unrelated ntdll syscall-emulation change. |
| `0259-ntdll-Implement-syscall-emulation-on-Linux-using-Sys` | Exclude | Unrelated ntdll Syscall User Dispatch implementation. |
| `0260-ntdll-Disable-syscall-dispatch-when-loading-a-.so-dl` | Exclude | Unrelated ntdll Syscall User Dispatch policy. |
| `0261-ntdll-Make-sure-User-Syscall-Dispatch-defines-are-al` | Exclude | Unrelated ntdll portability change. |
| `0262-ntdll-Fix-a-printf-format-warning` | Exclude | Unrelated ntdll warning fix. |
| `0263-kernel32-Add-stub-for-IsNativeVhdBoot` | Exclude | Unrelated kernel32 API stub. |
| `0264-wintrust-Add-parameter-check-in-WTHelperGetProvCertF` | Exclude | Unrelated WinTrust validation change. |
| `0265-winewayland-Use-WM_WINE_UPDATEWINDOWSTATE-to-update-` | Include | Generic WineWayland window-state lifecycle update. |
| `0266-winewayland-Don-t-activate-when-restoring-window` | Include | Generic restore/activation lifecycle fix. |
| `0267-ntdll-Search-for-the-library-containing-sa_restorer` | Exclude | Unrelated ntdll signal-restorer lookup. |
| `0268-ntdll-Allow-native-high-address-syscalls-with-SUD` | Exclude | Unrelated ntdll Syscall User Dispatch behavior. |
| `0268-winewayland-Move-pointer-warp-implementation-to-pSet` | Include | Generic WineWayland cursor-warp implementation update. |

## `0092` context-only adapter

Upstream `0092-winebus-Implement-PROTON_NO_STEAMINPUT-support.patch` does not
apply to the RTSP base because later Winebus context differs. Its seven inserted
lines are self-contained, so Beta 2 removes that exact upstream file from the
bundle and applies
`winebus-no-steaminput-ge-proton11-5-rtsp-adapter.patch` after the bundle. Only
the surrounding hunk context changed; the seven inserted lines are byte-for-byte
identical to upstream. Thus `PROTON_NO_STEAMINPUT` remains honoured both in the
Winebus udev backend and in `dlls/setupapi/devinst.c` through the unchanged
`winewayland-steam-input-ge-proton11-3-rtsp-adapter.patch`.

## Deterministic replay

All 152 bundled files replay cleanly in byte-sorted order on RTSP Wine base
`4a5f2736c5baf3d20ea7227b9da511e897ff9a2a`. Before local follow-ups, the
deterministic replay tree is
`d4ea950beeccae06f08c7f9103b1246119eedc4d`.

The context-only Winebus adapter and the unchanged Beta 1 SetupAPI and
WineWayland XR follow-ups then replay cleanly. The final 155-commit Wine tree is
`d6271f4e2c2f50a2a9bd113807de645ad608e3f8`.
