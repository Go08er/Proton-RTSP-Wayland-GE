<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Source and redistribution notice

Proton-RTSP-11.1-Wayland-GE is an unofficial assembly based on the projects listed below. It is not affiliated with or endorsed by Valve, CodeWeavers, GloriousEggroll, SpookySkeletons, Khronos, XRizer, WiVRn, Monado, or VRChat.

## Pinned source revisions

- RTSP Proton: `SpookySkeletons/proton-ge-rtsp` at `3b4a5f407a5e0cabeef6d3757f29a23f277b429a`
- RTSP Wine base: `fd920bd63abb7bf8b52b0f8e40da922ab9e784a4`
- GE patch reference: `GloriousEggroll/proton-ge-custom`, tag `GE-Proton11-1`, commit `fd07a035fadfbe989aef887cb999d0ef236c50d0`
- DXVK: `2cae043bdf767c8a7a2e0ee8d41537acfe773e8e`
- libxml2: `b7fa62cbe8ef0df5869e000d5b690bdedd07f33e`
- libxkbcommon: `dd642359f8d43c09968e34ca7f1eb1121b2dfd70`
- wayland-protocols: `810f1adaf33521cc55fc510566efba2a1418174f`
- xrandr source archive: version `1.5.4`, SHA-256 `2cafccb2aaf2491a4068676117a0d4f90ab307724b96fffc54cd1da953779400`
- piper-phonemize snapshot: `5ecbb9b59abcffe03a9775ae82491c9ac5037f4d`; original branch archive SHA-256 `728800cd310c64e6b6877866161b32ff0dc2d9c52ebdc54281fa21e448d2adef`, staged immutable archive SHA-256 `cd89aff6c3728776ffbf382bd6574876cc67d13402140fc5e3ec8c2bc813335f`
- eSpeak NG source: `0f65aa301e0d6bae5e172cc74197d32a6182200f`
- Xalia 0.4.9: `6d946216c29052c29c660ad4cac950a6bd08a2b4`
- SDL3-CS used by Xalia: `e26a111c1b90301e37475a4dfb6f5ce47447d677`
- Xalia 0.4.9 binary input archive SHA-256: `e2c94a40f68f63660cc06405a641bc4e5a2e9b9320b9608e01a21feb6f6709c5`

The Wine patch list contains 101 Wayland-focused patches selected from GE-Proton11-1. Unrelated GE patch groups are intentionally excluded. The X11 locale data used by the build is copied from the pinned GE source tree.

## Licensing

This is a multi-license distribution. No single license applies to the complete
compatibility tool.

- Original project scripts, documentation, tests, the patch-selection
  manifest, and project-authored Proton additions are BSD-3-Clause under
  `LICENSE`.
- Upstream Proton and RTSP top-level material retains BSD-3-Clause terms and
  original notices under `LICENSE.proton` and `LICENSE.upstream-proton`.
- Wine and the selected GE Wine patches remain LGPL-2.1-or-later under
  `LICENSE.wine` and `COPYING.LIB.wine`. Patch authorship is retained in the
  bundled format-patch files.
- All other components retain their own terms. `licenses/COMPONENTS.md` maps
  the principal payload, and binary packaging copies the exact license files
  from the prepared source tree into `licenses/upstream/`.

The project BSD license does not relicense Proton, Wine, GE patches, SDK
material, models, fonts, or another third-party component. A binary release
must be accompanied by the corresponding-source archive described in
`SOURCE.md`, particularly because the payload contains GPL and LGPL software.
