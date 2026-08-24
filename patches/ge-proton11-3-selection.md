<!-- SPDX-License-Identifier: BSD-3-Clause -->

# GE-Proton11-3 Wayland selection

Beta 1 selects 138 files from
`patches/wine-hotfixes/wine-wayland/` at annotated release
`GE-Proton11-3`, peeled commit
`8c8003f7f5473d883fbe1bc7ac070c79955754e8`.

```text
0002-0007
0009-0036
0038
0049-0054
0082-0085
0088-0105
0114-0128
0130-0134
0138-0148
0150
0156
0171
0178-0182
0184-0185
0187
0189-0214
0217-0219
0227-0230
```

The 99 excluded files are:

- 40 AMD/ATI/FSR-specific patches;
- 43 ntoskrnl/WDF/kernel-driver patches;
- four unrelated ntdll patches;
- three game-specific `wine.inf` workarounds;
- seven WindowsCodecs patches;
- two metadata or test-only patches.

The selected set keeps generic WineWayland display, input, lifecycle,
colorspace, OpenGL, and integration work. It also retains generic media fixes
`0213` and `0214` for absolute byte-stream seeking and empty-origin URL
handling. GE's separate video-rework patch directory is not included because
RTSP's GStreamer media stack remains authoritative.

All 138 files replay cleanly in byte-sorted order on RTSP Wine base
`fd920bd63abb7bf8b52b0f8e40da922ab9e784a4`. Before the two local Wine
follow-ups, the deterministic replay tree is
`cd63a44ac12c29ecac894a34cd141d976753f18d`.
