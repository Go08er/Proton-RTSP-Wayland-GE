#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause

# Alpha 2 development snapshot.  This is deliberately an immutable commit,
# even though it was selected from the moving Proton-GE master branch.
RTSP_COMMIT="3b4a5f407a5e0cabeef6d3757f29a23f277b429a"
RTSP_WINE_BASE="fd920bd63abb7bf8b52b0f8e40da922ab9e784a4"
RTSP_PIPER_COMMIT="9d06b74959570772e8bcbe7a3f696664d2421167"
FINAL_WINE_TREE="77ad524530fb09557af260ae6e50204bc42141c2"
FINAL_RTSP_TRACKED_DIFF_SHA256="7a99e11cb4e9ddc2f0986480ac10bfcaff75be2b4368f05c501621ae162ba963"
FINAL_WINEOPENXR_DIFF_SHA256="ab1b76f8e53adb7fba2a9546ac57a0b88fe90824fdf98318677e2b6425757457"
GE_COMMIT="9fad3bbe270409e67a8d2f4d123afc73d848306a"
GE_ROOT_TREE="8df051b27da31443f9624f0b62941a61cad1d957"
GE_LOCALE_TREE="7c8f3ed92d04fc80a139e3204d86650870e21d8f"
GE_WINE_COMMIT="c37dd7179b4c7716331d1f7ed401c469038fbe44"
GE_SOURCE_KIND="development-snapshot"
GE_SOURCE_LABEL="master-2026-07-13"
GE_WAYLAND_PATCH_DIR="ge-dev-9fad3bbe-wayland"
GE_WAYLAND_PATCH_COUNT="105"
GE_WAYLAND_PATCH_TREE="9e2198198a09fd538e74c42c202877d9c3d92fea"
GE_WINEOPENXR_PATCH="wineopenxr-decouple-9fad3bbe.patch"
GE_WINEOPENXR_BLOB="6921c98c5d0c14b3d541b67575867025ba842cfd"
GE_WINEOPENXR_SHA256="34234cca36c1a38c52e316ded723c6165ae1e76c7554ded013c560003efd21d2"
RTSP_WINEOPENXR_INTEGRATION_PATCH="wineopenxr-rtsp-makedep-integration.patch"
RTSP_WINEOPENXR_INTEGRATION_SHA256="ca0984589e2ed63425105ff2cdcf1a2d59a4e42e828144c44c316924f6d2508c"

# Dependency gitlinks from the exact GE root tree above.  Preparation verifies
# that each value still matches that tree before cloning or reusing it.
LIBXML2_COMMIT="b7fa62cbe8ef0df5869e000d5b690bdedd07f33e"
LIBXKBCOMMON_COMMIT="dd642359f8d43c09968e34ca7f1eb1121b2dfd70"
WAYLAND_PROTOCOLS_COMMIT="810f1adaf33521cc55fc510566efba2a1418174f"

XALIA_COMMIT="6d946216c29052c29c660ad4cac950a6bd08a2b4"
XALIA_SDL3_CS_COMMIT="e26a111c1b90301e37475a4dfb6f5ce47447d677"
XALIA_ZIP_NAME="xalia-0.4.9-net48-mono.zip"
XALIA_ZIP_SHA256="e2c94a40f68f63660cc06405a641bc4e5a2e9b9320b9608e01a21feb6f6709c5"

# Build-time archives cached under the otherwise-untracked contrib directory.
# The resume gate accepts only these exact names and content hashes.
WINE_GECKO_X86_NAME="wine-gecko-2.47.4-x86.tar.xz"
WINE_GECKO_X86_SHA256="2cfc8d5c948602e21eff8a78613e1826f2d033df9672cace87fed56e8310afb6"
WINE_GECKO_X86_64_NAME="wine-gecko-2.47.4-x86_64.tar.xz"
WINE_GECKO_X86_64_SHA256="fd88fc7e537d058d7a8abf0c1ebc90c574892a466de86706a26d254710a82814"
WINE_MONO_X86_NAME="wine-mono-11.0.0-x86.tar.xz"
WINE_MONO_X86_SHA256="0cd723aa28897f7d7d2702eed6c72e4262255980e212bc2b3c94bfa234abe5fd"
XRANDR_NAME="xrandr-1.5.4.tar.xz"
XRANDR_SHA256="2cafccb2aaf2491a4068676117a0d4f90ab307724b96fffc54cd1da953779400"

PIPER_PHONEMIZE_COMMIT="5ecbb9b59abcffe03a9775ae82491c9ac5037f4d"
PIPER_PHONEMIZE_ZIP_SHA256="cd89aff6c3728776ffbf382bd6574876cc67d13402140fc5e3ec8c2bc813335f"
PIPER_PATCH_SHA256="70b47942674bbd6b4fb2cc6722b8f640fc643cb419b89da8cf8f3f9e558f8645"

# GE-Proton11-2 swap procedure:
# 1. replace GE_COMMIT with the exact commit peeled from the release tag;
# 2. set GE_SOURCE_KIND=release and GE_SOURCE_LABEL=GE-Proton11-2;
# 3. regenerate the two GE patch bundles and every tree/blob/hash lock;
# 4. recompute the selection count and rerun every source/build audit.
