<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Principal component license map

This map summarizes the principal material in the compatibility-tool archive.
It is not a substitute for the original license files copied into
`licenses/upstream/` during packaging.

| Component or material | License | Primary bundled authority |
| --- | --- | --- |
| Original project scripts, documentation, tests, selection manifest, and project-authored Proton additions | BSD-3-Clause | `../LICENSE` |
| Proton and RTSP top-level code from pinned Proton-RTSP commit `f3f25735b3c4e37968c97417ede300bc836a6cd2` | BSD-3-Clause | `../LICENSE.proton`, `../LICENSE.upstream-proton`, `../config/upstream-pins.sh` |
| Wine; the active 160 exact main WineWayland patches and exact DDB cursor patch from pinned `GE-Proton11-6` (`7e88cefffc122ea1584c2156b8d7bae6cf69b2a7`); the retained published Beta 1 and Beta 2 provenance bundles; the three local Wine follow-ups; and the WineOpenXR integration modification | LGPL-2.1-or-later | `../LICENSE.wine`, `../COPYING.LIB.wine`, `../config/upstream-pins.sh`, `../patches/ge-proton11-6-selection.md`, `../patches/ge-proton11-5-selection.md`, `../patches/ge-proton11-3-selection.md`, `../patches/wineopenxr-rtsp-makedep-integration.patch` |
| DXVK | Zlib | `upstream/dxvk/LICENSE` |
| DXVK-NVAPI | MIT | `upstream/dxvk-nvapi/LICENSE` |
| vkd3d and vkd3d-proton | LGPL-2.1-or-later, with separately licensed subprojects | `upstream/vkd3d/`, `upstream/vkd3d-proton/` |
| OpenXR Loader | Apache-2.0 OR MIT | `upstream/OpenXR-SDK/` |
| OpenVR SDK and vrclient | BSD-3-Clause | `upstream/openvr/LICENSE`, `upstream/vrclient_x64/LICENSE` |
| GStreamer core and selected plugins | LGPL-family with file-level exceptions | `upstream/gstreamer/`, `upstream/gst-plugins-rs/` |
| FFmpeg used by gst-libav | LGPL-2.1-or-later in this build; GPL, nonfree, and version-3 options are disabled | `upstream/ffmpeg/` |
| dav1d | BSD-2-Clause plus AOM patent terms | `upstream/dav1d/COPYING`, archive `PATENTS.AV1` |
| Piper | MIT | `upstream/piper/LICENSE.md` |
| Project Piper dependency-pin patch | MIT, as a Piper modification | `upstream/piper/LICENSE.md`, `../patches/piper-phonemize-pin.patch` |
| piper-phonemize snapshot | MIT | `piper-phonemize-LICENSE` |
| ONNX Runtime 1.14.1 | MIT plus third-party notices | `onnxruntime-LICENSE`, `onnxruntime-ThirdPartyNotices` |
| eSpeak NG / libespeak-ng | GPL-3.0-or-later plus Apache, BSD-2-Clause, and Unicode data notices | `espeak-ng-COPYING*` |
| Vosk, Kaldi, and OpenFST | Apache-2.0 | `upstream/vosk-api/COPYING`, `upstream/kaldi/COPYING`, `upstream/openfst/COPYING` |
| ICU | Unicode-3.0 plus included third-party notices | `upstream/icu/LICENSE` |
| libxml2 | MIT | `libxml2-Copyright`, `upstream/libxml2/Copyright` |
| libxkbcommon | Multiple MIT/X11-family terms listed by upstream | `libxkbcommon-LICENSE`, `upstream/libxkbcommon/LICENSE` |
| Wayland protocols | MIT | `wayland-protocols-COPYING`, `upstream/wayland-protocols/COPYING` |
| xrandr 1.5.4 | MIT/X11-family | `xrandr-COPYING` |
| Copied X11 locale/Compose data | X.Org/libX11 license family | `X11-locale-COPYING` |
| Xalia 0.4.9 | MIT | `Xalia-LICENSE` |
| Xalia SDL3-CS and SDL3 | Zlib | `Xalia-SDL3-CS-LICENSE`, `Xalia-SDL3-LICENSE` |
| Xalia Superpower 3.1.0 | Apache-2.0 | `Xalia-Superpower-LICENSE` |
| Xalia Tmds.DBus.Protocol 0.92.0 | MIT | `Xalia-Tmds.DBus.Protocol-LICENSE` |
| Microsoft .NET runtime libraries shipped with Xalia | MIT plus third-party notices | `Xalia-dotnet-runtime-LICENSE`, `Xalia-dotnet-runtime-THIRD-PARTY-NOTICES` |
| Liberation, Noto, and Source Han font payloads | OFL-1.1 | archive `LICENSE.OFL`, font source notices under `upstream/fonts/` |
| lsteamclient Steamworks-derived material | Custom Steamworks SDK terms (`LicenseRef-Steamworks-SDK`) | `upstream/lsteamclient/LICENSE` |

The piper-phonemize repository carries `libtashkeel_model.ort` under the
repository-level MIT license; no separate model-specific notice was present in
the exact downloaded snapshot. This fact is recorded rather than inventing a
different license.

The X11 locale tree was copied from the pinned `GE-Proton11-6` release at
`7e88cefffc122ea1584c2156b8d7bae6cf69b2a7` without a local COPYING file. Its
layout and generated `locale.dir` were compared with
the official X.Org libX11 1.8.13 source; `locale.dir` is byte-identical while
the intentionally reduced Compose mapping differs. The full libX11 COPYING
file is therefore retained as the applicable provenance notice without
claiming that every locale byte came from an unmodified 1.8.13 archive.

Wine also embeds third-party libraries under `wine/libs/`, including Capstone,
compiler-rt, FAudio, FluidSynth, GSM, IJG JPEG, JPEG XR, LittleCMS, OpenLDAP,
mpg123, musl portions, libpng, SQLite, libtiff, LibTomCrypt, libxml2/libxslt,
and zlib. Their exact notices are preserved under `upstream/wine/libs/`.
