<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Beta 4 prepared for build — 2026-09-16

**Source preparation and no-build preflight passed. Compilation is on hold
at the maintainer's request.** No Beta 4 binary, installation, game result,
release archive or publication exists. Published Beta 3 and its Nix package
remain untouched.

Active worktree: `ge_on_rtsp/beta4/Proton-RTSP-Wayland-GE`, branch `beta4`,
based on published Beta 3 commit `7699ff4edc2fa0295c4719a93e61b1d951696b47`.
The recipe now targets Beta 4; the earlier groundwork commit was not
build-ready.

## Exact inputs and output locks

| Input | RTSP | GE |
| --- | --- | --- |
| Release | `proton-rtsp-11.0-20260609-4` | `GE-Proton11-7` |
| Tag type | Lightweight (`commit`) | Annotated (`tag`) |
| Tag ref object | `2faa9d3640bdd0139fc77d52bfd45db6b3807acd` | `4d2eb7396b175821d2a4beed97e3d36da3012bde` |
| Peeled commit | `2faa9d3640bdd0139fc77d52bfd45db6b3807acd` | `c191f35dcebbeccfacd3b4c6f6eea026e588c1c2` |
| Root tree | `9e8983db930052babb6f3ddc850db55de3e03b50` | `9ce007c8526d8c04d0face13dacff1612ff23c8b` |
| Wine gitlink | `fe6a2883bbe62967cd1da5044b7ceaf2c9a43dfe` | `46b29104e3741fe23bf5e2547196a253aab88c89` (provenance only) |

RTSP remains the Wine/GStreamer media base. This is **not** a GE Wine bump.
All dependency, blob and patch hashes are in `config/upstream-pins.sh`.

- Final Wine: **176 commits**, tree
  `0c7b3be3791ce1a4f5e53e2655b31d72cabcd3f6`.
- Prepared Proton tracked diff, excluding Wine/Piper gitlinks:
  `a90d019a61c8d146278c914fa960fd1e7f66fbc0304f38cde2869b591893904e`.
- WineOpenXR diff (unchanged from Beta 3):
  `7e9b9fabd2eabea87c2ea02975281026904c683e10a5a9d65451265597e46b84`.
- Tool name `Proton-RTSP-Wayland-GE-Beta4`; Steam display name
  `Proton RTSP Wayland GE Beta 4`; prefix identity `11.0-105`.

## Reviewed changes

RTSP -3 → -4 changes only its Wine gitlink, by one commit, `fe6a288`.
That changes only `dlls/mfmediaengine/video_frame_sink.c`: the video sample
queue defaults to five rather than two, with positive
`WINE_MFME_VIDEO_QUEUE_SIZE` values capped at sixteen. The setting is read
during sink creation into process-global state. Leave it unset for the
first future comparison. Reduced stalls are upstream's rationale, not a
measured result here; continuity, seek/replacement latency and A/V sync
remain runtime questions.

The [GE selection record](../patches/ge-proton11-7-selection.md) explains
169 main selections, three EM follow-ups and the exact cursor repair:
173 GE-derived Wine changes (171 exact applications, two context adapters).
Three established local follow-ups make 176. WineOpenXR changes are separate.

Two adapters retain every added/removed upstream line, changing only hunk
context: 0196 focus handling preserves RTSP's callback contract; 0048 retains
RTSP's inline input cleanup while adding output/token cleanup. The latter
is required with new 0290/0299 output-reference and activation behavior.
Standalone 0017 output-removal locking/lifetime and 0046 compositor keyboard
mapping apply unchanged. GE author attribution and originals are retained.

New main changes include clipboard NUL termination, output placement,
color-description/ICC lifetime and whitepoint correction, size-hint updates,
activation, and owner-hint probes. 0286 changes a surface-role predicate,
despite its “comments” subject; 0293 now requires `wl_output` version 4.

The 85-patch child-rendering subsystem, SNI, Reflex, overlay bridge and
unselected EM patches remain excluded. GE's newer DXVK, VKD3D-Proton,
WineDMO/FFmpeg and game-specific changes are not imported. RTSP's component
gitlinks remain authoritative. The two WineWayland VR extension mappings,
WineOpenXR/session repair and Steam Input policy are retained.

## Checks actually performed

- Fresh complete source materialization: 61 RTSP recursive gitlinks plus
  Xalia's SDL3-CS gitlink, and the three exact Wayland dependency commits.
  All submodules are at the pinned commits except Wine's locked 176-commit
  replay; Piper has only its pinned CMakeLists.txt change. No Git alternates
  dependency survives.
- Strict replay in the actual fresh build-source tree: all 176 Wine patches,
  root launcher/build patches, Piper pin and WineOpenXR changes passed.
  Each Wine patch passed `git apply --check`; no three-way fallback, fuzz,
  conflict resolution or rejects. Existing upstream whitespace warnings
  were retained, not edited away.
- Exact final Wine tree/count, root and WineOpenXR diff hashes, dependency
  pins, locale bytes and required XR/Steam Input symbols passed.
- All five cached Gecko/Mono/Xalia/xrandr inputs copied from the retained
  local source cache only after source hashes matched, then verified again
  at destination. The original files were not modified.
- `tests/preparation-gates.sh`: both real tag types accepted; six wrong
  type/object/commit cases rejected; matching preparation state accepted and
  changed type/adapter/follow-up/path state rejected; both adapters'
  added/removed lines match their exact upstream originals.
- `scripts/build.sh --check-only` passed on the actual prepared inputs,
  with the 16 = 8 × 2 worker budget. This mode never takes the lock,
  configures, compiles or packages.
- Bash syntax and Git whitespace checks passed. Focused ShellCheck on fetch,
  preparation, state helper and new gate tests passed. The wider check still
  reports existing build/export, unused-verifier-variable and license-manifest
  pipeline diagnostics; no claim of a warning-free entire repository.
- The cached SteamRT SDK was visible in separate Beta 4 container state.
  A network-disabled, read-only prerequisite container found GCC, Ninja and
  Meson and read the source mount with the expected rootless UID mapping.
  No compiler was invoked.

These are source and prerequisite checks, **not compilation or playback
evidence**.

## Prepared local paths and the next authorized command

Prepared source/state root:
`/tmp/proton-rtsp-wayland-ge-beta4-20260609-4`.
The success marker is `.prepared`; the RTSP root is
`sources/proton-ge-rtsp`. No configured build directory was created.

The local environment is `ge_on_rtsp/work/beta4-build.env`. It keeps HOME
unchanged, uses fresh Beta 4 container/run state, reuses the existing Beta 3
SDK as an additional read-only image store, and uses the shared Cargo/ccache
directories. Existing container policy is referenced, not changed.
Do not remove that image store or policy while this environment relies on them.

SDK image ID:
`65a5423161f5d45bc2c07d8ae36b61ace947d9b625984e3f264b137bab026d8b`.
Registry digest:
`sha256:97526b794ce1a9bed5f891084462260b3a02399569f7438a3a57b5a253001db9`.
The shared lock resolves to `$HOME/Documents/.proton-build.lock` with the
explicit local override; it was free and not taken during preparation.

From the Beta 4 repository, this is safe to repeat without building:

```sh
nix-shell --run 'source ../../work/beta4-build.env; bash scripts/build.sh --check-only'
```

**Only after the maintainer authorizes compilation**, recheck the shared
lock and ≥100 GB free-space floor, then:

```sh
nix-shell --run 'source ../../work/beta4-build.env; bash scripts/build.sh'
```

That environment sets `PACKAGE_RELEASE=0`, `JOBS=16`,
`ORCHESTRATOR_JOBS=8`, `COMPONENT_JOBS=2`. It does not authorize staging or
publication. Container image/toolchain and build-time external downloads
are not a promise of bit-identical or completely offline builds.

The RTSP release notes request `steam steam://unlockh264/` on the host.
It was **not run**. Discuss that client prerequisite at future staging,
without treating it as proof of a media repair.

## Local evidence and earlier probe

Ignored `logs/beta4-preparation/` holds fetch, dependency, replay, preflight,
submodule, archive and SDK evidence. Workspace
`ge_on_rtsp/work/beta4-upstreams-20260916/` retains the initial probes:
all 164 old Beta 3 patches passed on new RTSP Wine, tree
`9ff7a8e0e8272d815f53635db5b39d0baf75840a`; the first new-GE probe stopped
before 0196 after 111 patches, tree
`ae84e9b016db9e72950cb1e9e4fe2be7cf0b83f3`. That probe was subsequently
completed with the reviewed adapters; the fresh actual replay independently
reproduced the final tree above.

A local partial-clone seed for libxml2 lacked reachable promised objects;
the attempt failed, so all three Wayland dependencies were fetched by exact
commit from their declared remotes. No old source tree was repaired or reset.
No Steam/game launch, prefix access, installation, publication, build-lock
acquisition or separate-lineage edit was performed.

The new prepared tree occupies about 7.7 GiB; separate container metadata is
164 KiB and the retained preparation logs total about 56 KiB. About 240 GiB
remains free. The original Beta 3 worktree is still clean at `7699ff4e`.
Beta 4 recipe/documentation changes are left uncommitted for review.
