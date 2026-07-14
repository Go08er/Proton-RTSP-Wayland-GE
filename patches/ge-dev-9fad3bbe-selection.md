<!-- SPDX-License-Identifier: BSD-3-Clause -->

# GE development-snapshot selection

Alpha 2 selects 105 files from Proton-GE commit
`9fad3bbe270409e67a8d2f4d123afc73d848306a`. The selected files are the
following numeric ranges from `patches/wine-hotfixes/wine-wayland/`:

```text
0002-0007
0009-0036
0038
0049-0054
0082-0085
0088-0106
0115-0129
0131-0136
0140-0151
0153
0159
0174
0181-0185
```

The 80 omitted files comprise 22 AMD/ATI/FSR-specific changes, 42
ntoskrnl/WDF/kernel-driver changes, four unrelated ntdll timing/syscall
changes, three game-specific `wine.inf` workarounds, seven WindowsCodecs
changes, and two metadata/test-only patches (`0008` and `0037`).

Patch `0159` remains selected because it repairs conflicting GPU LUIDs before
registry population, which is relevant to hybrid-GPU and XR adapter identity.
Patch `0174` remains selected because its WineDMO/WineGStreamer behavior is
relevant to the RTSP media distribution.

The directory is replayed in byte-sorted order. `scripts/apply-patches.sh`
requires exactly 105 files and compares every file byte-for-byte with the
pinned GE Git tree before applying it. When GE-Proton11-2 appears, this
classification is regenerated against that tag; the Alpha 2 list is not
silently reused.
