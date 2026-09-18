<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Source and redistribution notice

Proton-RTSP-Wayland-GE Beta 4 is an unbuilt, unofficial candidate
based on the projects listed below. Published Beta 3, Beta 2, Beta 1, and Alpha 3
remain available separately and retain their own immutable source records.
This project is not affiliated with or endorsed by Valve, CodeWeavers,
GloriousEggroll, SpookySkeletons, Khronos, XRizer, WiVRn, Monado, or VRChat.

## Beta 4 pinned revisions

- RTSP lightweight tag `proton-rtsp-11.0-20260609-4` and commit:
  `2faa9d3640bdd0139fc77d52bfd45db6b3807acd`
- RTSP Wine base: `fe6a2883bbe62967cd1da5044b7ceaf2c9a43dfe`
- GE annotated tag `GE-Proton11-7`, object
  `4d2eb7396b175821d2a4beed97e3d36da3012bde`, peeled commit
  `c191f35dcebbeccfacd3b4c6f6eea026e588c1c2`
- GE Wine gitlink (provenance only): `46b29104e3741fe23bf5e2547196a253aab88c89`
- Final Wine tree: `0c7b3be3791ce1a4f5e53e2655b31d72cabcd3f6`

The active selection is 173 GE-derived Wine changes (171 exact applications
and two context adapters) plus three retained local follow-ups: 176 commits.
See `patches/ge-proton11-7-selection.md` for scope and attribution. The
85-patch child-rendering subsystem is excluded. Other component pins remain
as in the Beta 3 record below; prefix identity advances to `11.0-105`.
No compilation or runtime qualification is claimed for this candidate.

## Published Beta 3 pinned revisions

- RTSP Proton: `SpookySkeletons/Proton-RTSP` annotated tag
  `proton-rtsp-11.0-20260609-3`, tag object
  `60d1695539cb3e9205bd6d05d00cf4a30268b9e8`, peeled commit
  `f3f25735b3c4e37968c97417ede300bc836a6cd2`
- RTSP Wine base: `a7fcac55ca756e35d5dc0a7c8b70272d9c6a9675`
- Proton-GE release: annotated tag `GE-Proton11-6`, tag object
  `855db4875be1dee8c194b6e08abfe336babc126b`, peeled commit
  `7e88cefffc122ea1584c2156b8d7bae6cf69b2a7`
- Proton-GE Wine provenance: `9358696fe9a2261329f4a83aa6a65fd436106154`
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

Beta 3 carries 160 exact main WineWayland patches and GE's exact DDB cursor
patch, for 161 GE-derived changes. The Winebus and SetupAPI adapters and the
two-line WineWayland VR capability repair complete a 164-commit replay above
the RTSP Wine base, tree
`b256fa0664b725fdd55ab1f27820c52ea291000d`. The 58-patch child-rendering
stack, including its SNI and Reflex dependencies, and every other `em-fixups`
patch are not included. These source and replay facts do not establish runtime
behaviour. The launcher uses prefix identity `11.0-104`.

## Published Beta 2 pinned revisions

- RTSP Proton: `SpookySkeletons/Proton-RTSP` (formerly `proton-ge-rtsp`) annotated tag
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
