<!-- SPDX-License-Identifier: BSD-3-Clause -->

# GE-Proton11-6 Wayland selection

Beta 3 applies 160 exact files from
`patches/wine-hotfixes/wine-wayland/` at annotated release
`GE-Proton11-6`, peeled commit
`7e88cefffc122ea1584c2156b8d7bae6cf69b2a7`.

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
0247-0255
0263-0264
0266-0270
0272-0273
0280
0282-0283
```

The main GE WineWayland directory contains 275 patch files, so 115 files are
outside this bundle. The selection retains the generic WineWayland display,
input, window lifecycle, colorspace, OpenGL, media-integration, EDID, and IME
work that fits the RTSP Wine base. It continues to exclude AMD/ATI/FSR work,
ntoskrnl/WDF and other kernel-driver work, unrelated ntdll and EAC syscall
dispatch changes, WindowsCodecs work, game-specific `wine.inf` changes, and
other out-of-scope fixes.

The `mfmediaengine` sample-pump repair in Proton-RTSP patchset `-3` is already
part of the pinned RTSP Wine base
`a7fcac55ca756e35d5dc0a7c8b70272d9c6a9675`. It is not a selected GE patch and
is not replayed here.

## GE-Proton11-6 selection delta

One Beta 2 selection vanished upstream and nine newly relevant subjects enter
the main bundle. This changes the exact main-tree selection from 152 to 160
patches.

| Subject | Decision | Reason |
| --- | --- | --- |
| `winewayland: Treat fullscreen windows as resizeable.` | Removed upstream | The former fullscreen patch is absent from the GE-Proton11-6 main series and is not synthesized locally. |
| `win32u: Avoid a race condition when releasing / detaching a client surface.` | Include | Generic client-surface lifetime and race repair. |
| `win32u: Implement common EDID emulation code.` | Include | Introduces the shared EDID implementation required by the following WineWayland conversion. |
| `winewayland: Use common EDID generation in win32u.` | Include | Moves WineWayland onto the common EDID path. |
| `win32u: Don't return early if no monitor id is present.` | Include | Generic monitor enumeration correctness for the selected EDID path. |
| `HACK: winewayland: Reintroduce WAYLANDDRV_RAWINPUT.` | Include | Restores the selected native-Wayland raw-input path. |
| `winewayland: Do not lock wayland pointer when accessing frame.` | Include | Generic pointer-lock correctness. |
| `winewayland: Set names for winewayland threads.` | Include | Generic WineWayland thread identification and diagnostics. |
| `winewayland: Fix formatting of WAYLAND_WindowPosChanged.` | Include | Source-correctness cleanup within the selected WineWayland path. |
| `winewayland: Remove support for wlr_data_control_unstable_v1.` | Include | Keeps the selected clipboard/data-control implementation aligned with GE-Proton11-6. |

## Independent exact GE cursor repair

After the 160 main-series files, Beta 3 applies
`winewayland-render-ddb-cursors-ge-proton11-6.patch`. It is byte-identical to
GE-Proton11-6's
`patches/wine-hotfixes/em-fixups/winewayland-render-ddb-cursors-to-32bit-dib.patch`
and makes unsupported device-dependent cursor bitmaps render through a 32-bit
DIB. This is the 161st exact selected GE patch.

All other `em-fixups` patches remain excluded. In particular, the exact Steam
desktop virtual-controller filter is represented by the RTSP-context adapter
described below rather than counted as another exact replayed GE patch. GE's
separate video-rework directory remains excluded because RTSP's GStreamer media
architecture is authoritative, and the unrelated EAC/syscall-dispatch work is
also outside the established scope.

## Deliberately excluded child-rendering subsystem

GE-Proton11-6 adds the separate 58-patch
`patches/wine-hotfixes/wineland-child-rendering/` series. Beta 3 verifies its
upstream tree and count but deliberately does not import it. The series is an
atomic cross-process child-rendering subsystem with SNI and Reflex dependencies;
cherry-picking pieces would not be a defensible Wayland refresh and importing
the complete subsystem would materially widen this release's scope.

## Steam Input context adapters

Main-series
`0092-winebus-Implement-PROTON_NO_STEAMINPUT-support.patch` does not apply to
the older RTSP Winebus context. Beta 3 omits that exact file and follows the
main bundle with
`winebus-no-steaminput-ge-proton11-5-rtsp-adapter.patch`. Its seven inserted
Winebus lines remain byte-for-byte identical to upstream; only hunk context is
adapted.

GE-Proton11-6 also retains the exact Steam desktop virtual-controller filter at
`patches/wine-hotfixes/em-fixups/winewayland-ignore-steam-desktop-virtual-controller.patch`.
RTSP's older cfgmgr32 implementation forwards the affected enumeration calls
to SetupAPI, so Beta 3 represents that exact source policy with the existing
`winewayland-steam-input-ge-proton11-3-rtsp-adapter.patch`. Importing GE's
standalone cfgmgr32 hunk would duplicate the filter.

## Deterministic replay

The 160 main-series files replay in byte-sorted order on Proton-RTSP `-3` Wine
base `a7fcac55ca756e35d5dc0a7c8b70272d9c6a9675`, followed by the exact DDB cursor
patch. These 161 exact GE patches are followed by three local commits, in order:

1. the Winebus `PROTON_NO_STEAMINPUT` context adapter;
2. the SetupAPI Steam desktop virtual-controller adapter; and
3. the WineWayland XR capability repair.

The resulting 164-commit Wine tree is
`b256fa0664b725fdd55ab1f27820c52ea291000d`.
