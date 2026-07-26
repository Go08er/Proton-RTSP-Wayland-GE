<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Corresponding source

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
