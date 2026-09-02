<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Corresponding source

## Beta 3 candidate record

Beta 3 is an **unpublished local test candidate**. No Beta 3 tag, release, or
asset exists. `PACKAGE_RELEASE=0` remains required while it is reviewed and
tested.

Beta 3 retains Proton-RTSP's Wine lineage. GE's Wine is never checked out or
built by this project: selected GE patches are replayed onto the pinned RTSP
Wine base, while `GE_WINE_COMMIT` records the GE release's own gitlink only as
provenance.

The prepared Beta 3 source consists of:

- RTSP release `proton-rtsp-11.0-20260609-3`, annotated tag object
  `60d1695539cb3e9205bd6d05d00cf4a30268b9e8`, peeled to Proton commit
  `f3f25735b3c4e37968c97417ede300bc836a6cd2`;
- RTSP Wine base
  `a7fcac55ca756e35d5dc0a7c8b70272d9c6a9675`;
- the exact annotated `GE-Proton11-6` tag object
  `855db4875be1dee8c194b6e08abfe336babc126b`, peeled to commit
  `7e88cefffc122ea1584c2156b8d7bae6cf69b2a7`;
- 160 exact main WineWayland format patches plus GE's exact DDB cursor patch,
  for 161 GE-derived patches in the active replay;
- three local Wine follow-ups: the Winebus and SetupAPI Steam Input adapters
  and the two-line WineWayland OpenVR/OpenXR capability repair;
- GE's exact WineOpenXR decoupling patch, the source-equivalent session-list
  cleanup, and the RTSP one-line makedep adapter;
- the Beta 3 launcher patch with prefix identity `11.0-104`, dependency
  sources, X11 locale data, and license files.

The resulting RTSP Wine history is locked to 164 commits above its base and
tree `b256fa0664b725fdd55ab1f27820c52ea291000d`. The corresponding GE release's
Wine gitlink is `9358696fe9a2261329f4a83aa6a65fd436106154`; it is provenance, not a
build input.

The pinned RTSP 11-3 source adds anti-starvation sample-pump scheduling in
`mfmediaengine`. That is a source change, not evidence of runtime behaviour.
The 58-patch child-rendering stack, including its SNI and Reflex dependencies,
and every other `em-fixups` patch from GE-Proton11-6 are intentionally
excluded.

The Nix flake remains pinned to published Beta 2. Moving it to Beta 3 requires
a separate future publication decision.

## Published Beta 2 record

Beta 2 is published as `v11.1.0-beta.2`. Its release files are:

- `Proton-RTSP-Wayland-GE-Beta2.tar.gz`
- `Proton-RTSP-Wayland-GE-Beta2.tar.gz.sha512sum`
- `Proton-RTSP-Wayland-GE-Beta2-source.tar.gz`
- `Proton-RTSP-Wayland-GE-Beta2-source.tar.gz.sha512sum`

The build workflow invokes `scripts/package-corresponding-source.sh` only when
`PACKAGE_RELEASE=1` is explicitly selected. The default build does not create
release archives.

Beta 2 retains Proton-RTSP's Wine lineage. GE's Wine is never checked out or
built by this project: selected GE patches are replayed onto the pinned RTSP
Wine base, while `GE_WINE_COMMIT` records the GE release's own gitlink only as
provenance.

The published Beta 2 source consists of:

- RTSP release `proton-rtsp-11.0-20260609-2`, annotated tag object
  `315720bb897873e2f4a158c0b06d88d6198a8703`, peeled to Proton commit
  `c3ca33a4ebaf66cdebbac5e5fe432e342e395942`;
- RTSP Wine base
  `4a5f2736c5baf3d20ea7227b9da511e897ff9a2a`;
- the exact annotated `GE-Proton11-5` tag object
  `fc27a5029c7b90def3222b8fbaf33b69af973940`, peeled to commit
  `a2b6daedb7273267359ece9d938d6de8dec596b6`;
- 152 selected format-patch files copied byte-for-byte from that GE release,
  re-derived by patch subject because GE renumbered the series;
- a context-only Winebus adapter carrying GE's `PROTON_NO_STEAMINPUT` change,
  with the seven inserted lines unchanged from upstream;
- GE's exact WineOpenXR decoupling patch and the RTSP one-line makedep adapter;
- a source-equivalent backport of GE's WineOpenXR session-list cleanup;
- the unchanged RTSP-layout SetupAPI Steam Input adapter;
- the project-authored two-line WineWayland OpenVR/OpenXR capability repair;
- the Beta 2 launcher patch, dependency sources, X11 locale data, and license
  files.

The resulting RTSP Wine history is locked to 155 commits above its base and
tree `d6271f4e2c2f50a2a9bd113807de645ad608e3f8`. The corresponding GE release's
Wine gitlink is `36078f5f947532885a596dabbc7893c048133660`; it is not a build
input.

Three follow-up patches retain `ge-proton11-3` in their filenames. Their bytes
remain valid on the pinned GE-Proton11-5 composition, and their names record
the release from which they were originally derived.

The published Beta 1 GE patch bundle, selection record, and launcher patch and
the published Beta 2 bundle remain tracked as historical corresponding source.
Beta 3's active pins do not replay those older bundles.

## Beta 1 development record

Beta 1 is published as `v11.1.0-beta.1`. Its release files are:

- `Proton-RTSP-Wayland-GE-Beta1.tar.gz`
- `Proton-RTSP-Wayland-GE-Beta1.tar.gz.sha512sum`
- `Proton-RTSP-Wayland-GE-Beta1-source.tar.gz`
- `Proton-RTSP-Wayland-GE-Beta1-source.tar.gz.sha512sum`

The build workflow invokes `scripts/package-corresponding-source.sh` only when
`PACKAGE_RELEASE=1` is explicitly selected. The default build does not create
release archives.

The prepared Beta 1 source consists of:

- RTSP Proton commit
  `3b4a5f407a5e0cabeef6d3757f29a23f277b429a`;
- RTSP Wine base
  `fd920bd63abb7bf8b52b0f8e40da922ab9e784a4`;
- the exact annotated `GE-Proton11-3` tag object
  `1a65daf2708a7c8196f651ef4706a75deb56d7b5`, peeled to commit
  `8c8003f7f5473d883fbe1bc7ac070c79955754e8`;
- 138 selected format-patch files copied byte-for-byte from that GE release;
- GE's exact WineOpenXR decoupling patch and the RTSP one-line makedep adapter;
- a source-equivalent backport of GE-Proton11-3's WineOpenXR session-list
  cleanup;
- an RTSP-layout SetupAPI adapter for GE-Proton11-3's WineWayland Steam
  virtual-controller fix;
- the project-authored two-line WineWayland OpenVR/OpenXR Vulkan capability
  repair;
- the Beta 1 launcher patch, dependency sources, X11 locale data, and
  license files.

The resulting Wine history is locked to 140 commits above the RTSP Wine base
and tree `f795acc107bfff20ee6c9442beb151ed9be4ae84`. The corresponding
Proton-GE Wine gitlink is
`9578fa3613f3379179b576968bc77c8161ab6ea8`.

The `distribution/` directory in a source archive is exported only from a
clean, tracked Git revision. Packaging refuses tracked changes and unexpected
untracked files. Ignored logs, prefixes, build trees, and workspace data are
not copied.

## Published Alpha 3 record

The published `v11.1.0-alpha.3` release remains paired with:

- `Proton-RTSP-Wayland-GE-Alpha3-source.tar.gz`
- `Proton-RTSP-Wayland-GE-Alpha3-source.tar.gz.sha512sum`

Those files describe Alpha 3's `a5c30efa` development snapshot and must not be
relabeled as Beta 1 source. The tested Alpha 4 artifact and evidence likewise
remain Alpha 4 and are not relabeled.

## External source locks

- piper-phonemize:
  `5ecbb9b59abcffe03a9775ae82491c9ac5037f4d`, archive SHA-256
  `cd89aff6c3728776ffbf382bd6574876cc67d13402140fc5e3ec8c2bc813335f`;
- eSpeak NG: `0f65aa301e0d6bae5e172cc74197d32a6182200f`;
- Xalia 0.4.9:
  `6d946216c29052c29c660ad4cac950a6bd08a2b4`;
- Xalia SDL3-CS:
  `e26a111c1b90301e37475a4dfb6f5ce47447d677`;
- Xalia input archive SHA-256:
  `e2c94a40f68f63660cc06405a641bc4e5a2e9b9320b9608e01a21feb6f6709c5`;
- Wine Gecko 2.47.4 x86 and x86_64 archive SHA-256:
  `2cfc8d5c948602e21eff8a78613e1826f2d033df9672cace87fed56e8310afb6`
  and
  `fd88fc7e537d058d7a8abf0c1ebc90c574892a466de86706a26d254710a82814`;
- Wine Mono 11.0.0 x86 archive SHA-256:
  `0cd723aa28897f7d7d2702eed6c72e4262255980e212bc2b3c94bfa234abe5fd`;
- xrandr 1.5.4 source archive SHA-256:
  `2cafccb2aaf2491a4068676117a0d4f90ab307724b96fffc54cd1da953779400`.

The scripts verify Git trees, blobs, patches, dependency commits, and cached
archives before use. These locks support source reconstruction and review;
the container image, toolchain, and archive timestamps are not sufficiently
pinned to promise bit-identical binary output.
