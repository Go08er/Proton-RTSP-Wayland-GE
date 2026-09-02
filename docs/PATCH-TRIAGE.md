# Historical Alpha 3 Wayland patch triage

This table preserves the published Alpha 3 classification for Proton-GE
snapshot `a5c30efa`. It is not the active Beta 3 candidate patch list. The
published Beta 1 record remains in
[`../patches/ge-proton11-3-selection.md`](../patches/ge-proton11-3-selection.md);
see [`../patches/ge-proton11-5-selection.md`](../patches/ge-proton11-5-selection.md)
for published Beta 2's 152-file selection.

The local Beta 3 candidate is defined by
[`../patches/ge-proton11-6-selection.md`](../patches/ge-proton11-6-selection.md)
and [`../config/upstream-pins.sh`](../config/upstream-pins.sh): 160 exact main
WineWayland patches plus GE's exact DDB cursor patch, followed by three local
Wine follow-ups. The 58-patch child-rendering stack, including its SNI and
Reflex dependencies, and every other `em-fixups` patch are intentionally
excluded. The locked result is 164 commits above the RTSP 11-3 Wine base, tree
`b256fa0664b725fdd55ab1f27820c52ea291000d`; this is source evidence, not a
runtime result.

| # | subject | area | class | vrchat | note |
| --- | --- | --- | --- | --- | --- |
| 0002 | win32u: Reorder KEYEVENTF_SCANCODE handling control flow. | win32u | INPUT | LIKELY | |
| 0003 | winewayland: Assign a name to the winewayland queue. | winewayland.drv | PERIPHERAL | NO | Names the event queue for diagnostics. |
| 0004 | winewayland: Change default debug channel to cursor for pointer. | winewayland.drv | PERIPHERAL | NO | Debug-channel routing only. |
| 0005 | winewayland: Use process_name in wl_display_create_queue_with_name for debugging. | winewayland.drv | PERIPHERAL | NO | Queue naming only. |
| 0006 | winewayland: Treat maximized+fullscreen state as fullscreen. | winewayland.drv | DISPLAY | YES | |
| 0007 | win32u: Always flush the window surface in expose_window_surface. | win32u | CORE | LIKELY | |
| 0009 | winewayland: Implement min/max size hints for non-resizeable windows. | winewayland.drv | DISPLAY | LIKELY | |
| 0010 | winewayland: Make sure the primary monitor rect is at 0x0. | winewayland.drv | DISPLAY | LIKELY | |
| 0011 | winewayland: Do not place_above on a detached client surface. | winewayland.drv | CORE | LIKELY | |
| 0012 | winewayland: Use wp_pointer_warp_v1 for SetCursorPos when available. | winewayland.drv | INPUT | YES | |
| 0013 | winewayland.drv: Add alpha-modifier-v1 protocol to support change alpha by WAYLAND_SetLayeredWindowAttributes. | winewayland.drv | PERIPHERAL | UNKNOWN | |
| 0014 | winewayland.drv: Add WAYLAND_UpdateLayeredWindow and add support for changing alpha using the alpha-modifier-v1 protocol. | winewayland.drv | PERIPHERAL | UNKNOWN | |
| 0015 | winewayland: Implement fractional scaling protocol. | winewayland.drv | DISPLAY | LIKELY | |
| 0016 | winewayland: Fix missing wayland_win_data_release. | winewayland.drv | DISPLAY | LIKELY | |
| 0017 | win32u: Use surfaces for client area if the backend doesn't support PutImage. | win32u | CORE | YES | |
| 0018 | server: Fix numpad vkey handling. | server | INPUT | UNKNOWN | |
| 0019 | win32u: Remap some scancodes to better match native behavior. | win32u | INPUT | LIKELY | |
| 0020 | winewayland: Store the pending warp position. | winewayland.drv | INPUT | YES | |
| 0021 | winewayland: Rename toplevel_hwnd to owner_hwnd. | winewayland.drv | PERIPHERAL | NO | Identifier-only refactor. |
| 0022 | winewayland: Make window lock mutex recursive. | winewayland.drv | CORE | YES | |
| 0023 | winewayland: Move ensure_window_surface_contents into wayland_surface.c. | winewayland.drv | PERIPHERAL | NO | Code motion only. |
| 0024 | winewayland: Use RECT / POINT to map coordinates from surface. | winewayland.drv | INPUT | YES | |
| 0025 | winewayland: Use RECT / POINT to map coordinates to surface. | winewayland.drv | INPUT | YES | |
| 0026 | winewayland: Use a RECT in struct wayland_surface_config. | winewayland.drv | DISPLAY | LIKELY | |
| 0027 | winewayland: Use update_client_surfaces to detach client surfaces. | winewayland.drv | CORE | YES | |
| 0028 | winewayland: Remove unnecessary client surface attach / detach. | winewayland.drv | CORE | YES | |
| 0029 | winewayland: Implement exclusive fullscreen ensure contents. | winewayland.drv | DISPLAY | YES | |
| 0030 | winewayland: Fix formatting issues. | winewayland.drv | PERIPHERAL | NO | Formatting only. |
| 0031 | winewayland: Implement xdg-popup for unmanaged windows. | winewayland.drv | CORE | UNKNOWN | |
| 0032 | winewayland: Support wl_seat version 8. | winewayland.drv | INPUT | LIKELY | |
| 0033 | winewayland: Fix build error with older wl_pointer interface. | winewayland.drv | BUILD | NO | Conditional compile guard only. |
| 0034 | winewayland: Fix non-square icons with xdg-toplevel-icon protocol. | winewayland.drv | PERIPHERAL | UNKNOWN | |
| 0035 | win32u: Add SetIMEEnabled driver call. | win32u | IME | UNKNOWN | |
| 0036 | winewayland: Implement SetIMEEnabled driver call. | winewayland.drv | IME | UNKNOWN | |
| 0038 | win32u: Call SetIMEEnabled from NtUserAssociateInputContext. | win32u | IME | UNKNOWN | |
| 0049 | winewayland: Add error message for failure to allocate client surface. | winewayland.drv | PERIPHERAL | NO | Diagnostic message only. |
| 0050 | winewayland: Introduce WAYLAND_HasWindowManager. | winewayland.drv | PERIPHERAL | UNKNOWN | |
| 0051 | win32u: Create window surface for client surface on winewayland. | win32u | CORE | YES | |
| 0052 | winewayland: Implement ext-data-control-v1. | winewayland.drv | PERIPHERAL | UNKNOWN | |
| 0053 | winewayland: Switch mode width and height on rotated displays. | winewayland.drv | DISPLAY | UNKNOWN | |
| 0054 | winewayland: respect size hint when restoring from tiled states. | winewayland.drv | DISPLAY | UNKNOWN | |
| 0082 | winewayland: Add support for xdg-toplevel-tag-v1. | winewayland.drv | PERIPHERAL | LIKELY | |
| 0083 | winewayland: Implement wp_content_type_v1. | winewayland.drv | PERIPHERAL | LIKELY | |
| 0084 | winewayland: Put fullscreen windows on associated output. | winewayland.drv | DISPLAY | YES | |
| 0085 | HACK: win32u: Implement window move hack | win32u | DISPLAY | UNKNOWN | |
| 0088 | win32u: Track swapchain/opengl reference of client surface. | win32u | CORE | YES | |
| 0089 | win32u: Avoid re-inserting the same client surface twice. | win32u | CORE | YES | |
| 0090 | winewayland: Implement support for server side decorations. | winewayland.drv | PERIPHERAL | UNKNOWN | |
| 0091 | winewayland: Implement client surface caching. | winewayland.drv | CORE | YES | |
| 0092 | winewayland: Implement minimize & restore of windows. | winewayland.drv | DISPLAY | UNKNOWN | |
| 0093 | winewayland: Implement app triggered window restore. | winewayland.drv | DISPLAY | UNKNOWN | |
| 0094 | winewayland: Move pointer input processing to frame event. | winewayland.drv | INPUT | YES | |
| 0095 | winewayland: Implement touchpad scrolling. | winewayland.drv | INPUT | UNKNOWN | |
| 0096 | winewayland: Always use relative motion. | winewayland.drv | INPUT | YES | |
| 0097 | winebus: Implement PROTON_NO_STEAMINPUT support. | winebus | INPUT | UNKNOWN | |
| 0098 | winebus: Implement PROTON_EMULATE_STEAMINPUT. | winebus | INPUT | UNKNOWN | |
| 0099 | winewayland: Implement edid emulation. | winewayland.drv | DISPLAY | LIKELY | |
| 0100 | winewayland: Implement support for wl_output geometry events. | winewayland.drv | DISPLAY | LIKELY | |
| 0101 | winewayland: Implement support for color management protocol. | winewayland.drv | DISPLAY | UNKNOWN | |
| 0102 | winewayland: Implement support for FlashWindow. | winewayland.drv | PERIPHERAL | UNKNOWN | |
| 0103 | win32u: Pass appropriate thread id for KEYEVENTF_SCANCODE. | win32u | INPUT | LIKELY | |
| 0104 | server: Store keyboard layout in thread struct. | server | INPUT | LIKELY | |
| 0105 | win32u: Implement cross thread keyboard layout query. | win32u | INPUT | LIKELY | |
| 0106 | win32u: Don't grab the layout twice. | win32u | INPUT | LIKELY | |
| 0115 | winewayland: Implement support for DXVK_NO_HDR. | winewayland.drv | DISPLAY | UNKNOWN | |
| 0116 | winewayland: Generate KBDTABLES dead key tables. | winewayland.drv | INPUT | UNKNOWN | |
| 0117 | win32u: Implement KBDTABLES dead key ToUnicodeEx and GetKeyNameText. | win32u | INPUT | UNKNOWN | |
| 0118 | win32u: Implement wide vk2char conversion. | win32u | INPUT | UNKNOWN | |
| 0119 | win32u: Implement dead key support for MAPVK_VK_TO_CHAR. | win32u | INPUT | UNKNOWN | |
| 0120 | user32: Implement dead key support for MapVirtualKeyExA. | other | INPUT | UNKNOWN | |
| 0121 | loader: Add Keyboard Layouts registry enteries. | other | INPUT | UNKNOWN | |
| 0122 | user32: Do not enumerate the registry in GetKeyboardLayoutList(). | win32u | INPUT | UNKNOWN | |
| 0123 | winewayland: Implement monitor ranking to determine primary. | winewayland.drv | DISPLAY | LIKELY | |
| 0124 | HACK: winewayland: Implement WAYLANDDRV_PRIMARY_MONITOR env. | winewayland.drv | DISPLAY | UNKNOWN | |
| 0125 | winewayland: Implement modifier key support. | winewayland.drv | INPUT | LIKELY | |
| 0126 | win32u: Implement user driver colorspace overrides. | win32u | DISPLAY | UNKNOWN | |
| 0127 | HACK: winewayland: Implement shortcut inhibitor. | winewayland.drv | INPUT | UNKNOWN | |
| 0128 | HACK: winewayland: Use version 5 of wl_seat. | winewayland.drv | INPUT | LIKELY | |
| 0129 | HACK: ntdll: Make load_steam_overlay work with winewayland. | other | PERIPHERAL | LIKELY | |
| 0131 | winewayland: Use passthrough for some colorspaces. | winewayland.drv | DISPLAY | UNKNOWN | |
| 0132 | win32u: Silence DISPLAYCONFIG_DEVICE_INFO_GET_ADVANCED_COLOR_INFO fixme. | win32u | PERIPHERAL | NO | Logging rate limit only. |
| 0133 | winewayland: Improve some traces. | winewayland.drv | PERIPHERAL | NO | Trace detail only. |
| 0134 | HACK: winewayland/opengl: Implement swap interval override. | winewayland.drv | DISPLAY | UNKNOWN | |
| 0135 | HACK: winewayland: Add env to disable focus loss. | winewayland.drv | INPUT | UNKNOWN | |
| 0136 | winewayland: Do not unmap SLWA windows with no attributes set. | winewayland.drv | PERIPHERAL | UNKNOWN | |
| 0140 | winegstreamer: Don't force x11 display type. | winegstreamer | PERIPHERAL | LIKELY | Allows GStreamer to choose a non-X11 display backend. |
| 0141 | winewayland: Implement brazil ABNT keyboard layout. | winewayland.drv | INPUT | UNKNOWN | |
| 0142 | win32u: Reduce log spam of NtUserActivateKeyboardLayout. | win32u | PERIPHERAL | NO | Logging rate limit only. |
| 0143 | ime: Reduce log spam of ImeSetCompositionString. | other | IME | NO | Logging rate limit only. |
| 0144 | winewayland: Don't post IME update on leave unless text input is enabled | winewayland.drv | IME | UNKNOWN | |
| 0145 | winewayland: Require wl_seat version 3. | winewayland.drv | INPUT | LIKELY | |
| 0146 | winewayland: Implement touch input. | winewayland.drv | INPUT | UNKNOWN | |
| 0147 | winewayland: Add missing traces for client surfaces. | winewayland.drv | PERIPHERAL | NO | Trace additions only. |
| 0148 | win32u: Remove duplicate definition. | include | BUILD | NO | Header cleanup only. |
| 0149 | winewayland: Don't rely on win32u keystate for release_all_keys. | winewayland.drv | INPUT | LIKELY | |
| 0150 | winewayland: Add a third roundtrip during init. | winewayland.drv | CORE | YES | |
| 0151 | win32u: Add WINE_ENABLE_HARDWARE_SCHEDULING option. | win32u | PERIPHERAL | UNKNOWN | |
| 0153 | win32u: Fix NtUserEnableMouseInPointer to respect the enable parameter. | win32u | INPUT | UNKNOWN | |
| 0159 | win32u: Fixup LUID conflicts before writing GPU to registry. | win32u | DISPLAY | LIKELY | |
| 0174 | HACK: winegstreamer: Add semi-stub for GetAttributeIndices/GetAttributeByIndexEx. | winegstreamer | PERIPHERAL | UNKNOWN | Media-format dependent Windows Media Reader path. |
| 0181 | winewayland: Use present rect to check for exclusive fullscreen. | winewayland.drv | DISPLAY | YES | |
| 0182 | winewayland: Don't initialize the win_data_mutex statically. | winewayland.drv | CORE | YES | |
| 0183 | server: Use MOUSEEVENTF_MOVE if the cursor win changes. | server | INPUT | LIKELY | |
| 0184 | win32u: Fix is_window_visible/drawable when topmost window is the desktop window of another thread. | win32u | CORE | LIKELY | |
| 0185 | winewayland: Treat 0x0 windows as roleless. | winewayland.drv | CORE | LIKELY | |
| 0187 | winewayland: Fix y coordinate of IME cursor rectangle. | winewayland.drv | IME | LIKELY | |
| 0188 | fixup! winewayland: Do not recursively lock with NtUserMessageCall. | winewayland.drv | CORE | YES | Prevents a compositor-thread deadlock. |
| 0190 | winewayland: Fix race between processing and requested configuration. | winewayland.drv | DISPLAY | LIKELY | |
| 0192 | winewayland: Set an event queue name for the buffer queue. | winewayland.drv | PERIPHERAL | NO | Queue naming only. |
| 0193 | winewayland: Log protocol errors when they occur. | winewayland.drv | PERIPHERAL | NO | Diagnostics only. |

## Summary

- Class counts: CORE 16; INPUT 34; DISPLAY 25; IME 6; VR 0; PERIPHERAL 27; BUILD 2.
- VRChat counts: YES 21; LIKELY 31; NO 16; UNKNOWN 42.
- `UNKNOWN`: 0013, 0014, 0018, 0031, 0034, 0035, 0036, 0038, 0050, 0052, 0053, 0054, 0085, 0090, 0092, 0093, 0095, 0097, 0098, 0101, 0102, 0115, 0116, 0117, 0118, 0119, 0120, 0121, 0122, 0124, 0126, 0127, 0131, 0134, 0135, 0136, 0141, 0144, 0146, 0151, 0153, 0174.
