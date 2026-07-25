<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Source and redistribution notice

Proton-RTSP-Wayland-GE Alpha 3 is an unofficial assembly based on the projects
listed below. It is not affiliated with or endorsed by Valve, CodeWeavers,
GloriousEggroll, SpookySkeletons, Khronos, XRizer, WiVRn, Monado, or VRChat.
Alpha 3 is currently a local development candidate. It must not be presented
as a tested release until its build, artifact, and game-test gates pass.

## Pinned source revisions

- RTSP Proton: `SpookySkeletons/proton-ge-rtsp` at `3b4a5f407a5e0cabeef6d3757f29a23f277b429a`
- RTSP Wine base: `fd920bd63abb7bf8b52b0f8e40da922ab9e784a4`
- GE patch reference: `GloriousEggroll/proton-ge-custom`, development snapshot
  `master-2026-07-24`, commit
  `a5c30efa111c6a834395e70da88c801536c68f6d` (not GE-Proton11-2)
- Proton-GE Wine commit: `fc39a66977983a16a31318f98386386ec2dd6b55`
- DXVK: `2cae043bdf767c8a7a2e0ee8d41537acfe773e8e`
- libxml2: `b7fa62cbe8ef0df5869e000d5b690bdedd07f33e`
- libxkbcommon: `dd642359f8d43c09968e34ca7f1eb1121b2dfd70`
- wayland-protocols: `810f1adaf33521cc55fc510566efba2a1418174f`
- xrandr source archive: version `1.5.4`, SHA-256 `2cafccb2aaf2491a4068676117a0d4f90ab307724b96fffc54cd1da953779400`
- piper-phonemize snapshot: `5ecbb9b59abcffe03a9775ae82491c9ac5037f4d`; Alpha 3 immutable archive SHA-256 `cd89aff6c3728776ffbf382bd6574876cc67d13402140fc5e3ec8c2bc813335f` (the earlier mutable branch archive is historical and is not an Alpha 3 input)
- eSpeak NG source: `0f65aa301e0d6bae5e172cc74197d32a6182200f`
- Xalia 0.4.9: `6d946216c29052c29c660ad4cac950a6bd08a2b4`
- SDL3-CS used by Xalia: `e26a111c1b90301e37475a4dfb6f5ce47447d677`
- Xalia 0.4.9 binary input archive SHA-256: `e2c94a40f68f63660cc06405a641bc4e5a2e9b9320b9608e01a21feb6f6709c5`
- Wine Gecko 2.47.4 x86 archive SHA-256: `2cfc8d5c948602e21eff8a78613e1826f2d033df9672cace87fed56e8310afb6`
- Wine Gecko 2.47.4 x86_64 archive SHA-256: `fd88fc7e537d058d7a8abf0c1ebc90c574892a466de86706a26d254710a82814`
- Wine Mono 11.0.0 x86 archive SHA-256: `0cd723aa28897f7d7d2702eed6c72e4262255980e212bc2b3c94bfa234abe5fd`

The Alpha 3 Wine patch list contains 110 Wayland-focused patches copied from
the pinned Proton-GE snapshot. The build also applies that snapshot's exact
`patches/wineopenxr/wineopenxr_decouple.patch` to RTSP's standalone WineOpenXR
source, followed by a hash-locked one-line RTSP build-system adapter that keeps
the makedep wrapper's required `ntdll.so` input. Unrelated GE patch groups are
intentionally excluded. The X11 locale data used by the build is copied from
the same pinned GE source tree.

## Licensing

This is a multi-license distribution. No single license applies to the complete
compatibility tool.

- Original project scripts, documentation, tests, the patch-selection
  manifest, and project-authored Proton additions are BSD-3-Clause under
  `LICENSE`.
- Upstream Proton and RTSP top-level material retains BSD-3-Clause terms and
  original notices under `LICENSE.proton` and `LICENSE.upstream-proton`.
- Wine, the selected GE Wine patches, and the project WineOpenXR integration
  modification remain LGPL-2.1-or-later under `LICENSE.wine` and
  `COPYING.LIB.wine`. Patch authorship is retained in the bundled format-patch
  files.
- All other components retain their own terms. `licenses/COMPONENTS.md` maps
  the principal payload, and binary packaging copies the exact license files
  from the prepared source tree into `licenses/upstream/`.

The project BSD license applies only to original project material. It does not
relicense Proton, Wine, the GE Wine patches, an SDK-derived file, model, font,
or another third-party component.

Binary archives are paired with a complete prepared-source archive and
checksum as described in [`SOURCE.md`](SOURCE.md). Pinned revisions support
source reconstruction and review; the current toolchain is not sufficiently
pinned to promise bit-identical binary reproduction.
