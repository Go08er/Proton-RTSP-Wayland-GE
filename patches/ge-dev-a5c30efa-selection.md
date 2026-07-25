<!-- SPDX-License-Identifier: BSD-3-Clause -->

# GE development-snapshot selection

Alpha 3 selects 110 files from Proton-GE commit
`a5c30efa111c6a834395e70da88c801536c68f6d`. The selected files are the
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
0187-0188
0190
0192-0193
```

The 83 omitted files comprise 24 AMD/ATI/FSR-specific changes, 43
ntoskrnl/WDF/kernel-driver changes, four unrelated ntdll timing/syscall
changes, three game-specific `wine.inf` workarounds, seven WindowsCodecs
changes, and two metadata/test-only patches (`0008` and `0037`).

Patch `0159` remains selected because it repairs conflicting GPU LUIDs before
registry population, which is relevant to hybrid-GPU and XR adapter identity.
Patch `0174` remains selected because its WineDMO/WineGStreamer behavior is
relevant to the RTSP media distribution.
Patch `0092` changed in this snapshot: managed minimized windows now receive
both restore and foreground handling, while unmanaged minimized surfaces no
longer take the restore path. Minimize and restore behavior therefore needs
focused Alpha 3 testing.

The directory is replayed in byte-sorted order. `scripts/apply-patches.sh`
requires exactly 110 files and compares every file byte-for-byte with the
pinned GE Git tree before applying it. When GE-Proton11-2 appears, this
classification is regenerated against that tag; the Alpha 3 list is not
silently reused.
