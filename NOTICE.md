<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Source and redistribution notice

Proton-RTSP-Wayland-GE Beta 1 is an unpublished, unofficial assembly based on
the projects listed below. Published Alpha 3 remains available separately and
retains its own immutable source record. This project is not affiliated with
or endorsed by Valve, CodeWeavers, GloriousEggroll, SpookySkeletons, Khronos,
XRizer, WiVRn, Monado, or VRChat.

## Beta 1 pinned revisions

- RTSP Proton: `SpookySkeletons/Proton-RTSP` (formerly `proton-ge-rtsp`) at
  `3b4a5f407a5e0cabeef6d3757f29a23f277b429a`
- RTSP Wine base: `fd920bd63abb7bf8b52b0f8e40da922ab9e784a4`
- Proton-GE release: annotated tag `GE-Proton11-3`, tag object
  `1a65daf2708a7c8196f651ef4706a75deb56d7b5`, peeled commit
  `8c8003f7f5473d883fbe1bc7ac070c79955754e8`
- Proton-GE Wine: `9578fa3613f3379179b576968bc77c8161ab6ea8`
- DXVK: `2cae043bdf767c8a7a2e0ee8d41537acfe773e8`
- libxml2: `b7fa62cbe8ef0df5869e000d5b690bdedd07f33e`
- libxkbcommon: `dd642359f8d43c09968e34ca7f1eb1121b2dfd70`
- Wayland Protocols: `810f1adaf33521cc55fc510566efba2a1418174f`
- xrandr 1.5.4 archive SHA-256:
  `2cafccb2aaf2491a4068676117a0d4f90ab307724b96fffc54cd1da953779400`
- piper-phonemize:
  `5ecbb9b59abcffe03a9775ae82491c9ac5037f4d`, archive SHA-256
  `cd89aff6c3728776ffbf382bd6574876cc67d13402140fc5e3ec8c2bc813335f`
- Xalia 0.4.9:
  `6d946216c29052c29c660ad4cac950a6bd08a2b4`
- Xalia SDL3-CS:
  `e26a111c1b90301e37475a4dfb6f5ce47447d677`

Beta 1 carries 138 selected Wine patches byte-for-byte from the pinned GE
release, plus its exact WineOpenXR decoupling patch. The separate
WineOpenXR session-lifetime patch is a source-equivalent backport from the
same release. The Steam controller patch is a semantic adapter: the older RTSP
Wine layout routes cfgmgr32 enumeration through SetupAPI, so only GE's SetupAPI
half is required. The two-line WineWayland VR capability repair and Beta 1
launcher integration are project-authored. Exact attribution is retained in
each format patch.

## Licensing

This is a multi-license distribution; no single license applies to the entire
compatibility tool.

- Original project scripts, documentation, tests, selection records, and
  project-authored additions are BSD-3-Clause under `LICENSE`.
- Upstream Proton and RTSP material retains BSD-3-Clause terms and original
  notices under `LICENSE.proton` and `LICENSE.upstream-proton`.
- Wine, the selected GE Wine patches, and WineOpenXR modifications remain
  LGPL-2.1-or-later under `LICENSE.wine` and `COPYING.LIB.wine`.
- All other components retain their own terms. `licenses/COMPONENTS.md` maps
  the principal payload, and packaging copies notices from the prepared source
  tree into `licenses/upstream/`.

The project BSD license does not relicense third-party components. Any binary
archive must remain paired with the corresponding prepared-source archive and
checksums described in [`SOURCE.md`](SOURCE.md).
