<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Source and redistribution notice

Proton-RTSP-Wayland-GE Beta 2 is an unpublished, unofficial assembly based on
the projects listed below. Published Beta 1 and Alpha 3 remain available
separately and retain their own immutable source records. This project is not
affiliated with or endorsed by Valve, CodeWeavers, GloriousEggroll,
SpookySkeletons, Khronos, XRizer, WiVRn, Monado, or VRChat.

## Beta 2 pinned revisions

- RTSP Proton: `SpookySkeletons/Proton-RTSP` annotated tag
  `proton-rtsp-11.0-20260609-2`, tag object
  `315720bb897873e2f4a158c0b06d88d6198a8703`, peeled commit
  `c3ca33a4ebaf66cdebbac5e5fe432e342e395942`
- RTSP Wine base: `4a5f2736c5baf3d20ea7227b9da511e897ff9a2a`
- Proton-GE release: annotated tag `GE-Proton11-5`, tag object
  `fc27a5029c7b90def3222b8fbaf33b69af973940`, peeled commit
  `a2b6daedb7273267359ece9d938d6de8dec596b6`
- Proton-GE Wine provenance: `36078f5f947532885a596dabbc7893c048133660`
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

Beta 2 carries 152 selected Wine patches byte-for-byte from the pinned GE
release. A context-only Winebus adapter preserves upstream's seven-line
`PROTON_NO_STEAMINPUT` change on the RTSP Wine layout; the unchanged SetupAPI
adapter, two-line WineWayland VR capability repair, and launcher integration
complete a 155-commit replay above the RTSP Wine base. The exact WineOpenXR
decoupling patch remains byte-identical in GE-Proton11-5, while the separate
session-lifetime patch is a source-equivalent backport from the release where
it originated. Exact attribution is retained in each format patch.

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
