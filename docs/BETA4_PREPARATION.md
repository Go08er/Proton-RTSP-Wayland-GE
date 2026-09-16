<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Beta 4 groundwork — 2026-09-16

Status: source investigation and replay probes only. This local `beta4`
branch starts at published Beta 3, `7699ff4edc2fa0295c4719a93e61b1d951696b47`.
There is no Beta 4 artifact, completed preparation marker, or build-ready
configuration. Active scripts, pins, and the Nix package still describe Beta
3 until the new replay is complete. Do not run the inherited build command
expecting Beta 4.

The maintainer requested groundwork for these exact releases:

- [Proton-RTSP 11.0-20260609-4](https://github.com/SpookySkeletons/proton-rtsp/releases/tag/proton-rtsp-11.0-20260609-4)
- [GE-Proton11-7](https://github.com/GloriousEggroll/proton-ge-custom/releases/tag/GE-Proton11-7)

## Verified upstream identities

These values were derived from isolated Git fetches, not copied from release
text. They are proposed Beta 4 inputs, not replacements for Beta 3's locks.

| Input | RTSP | GE |
| --- | --- | --- |
| Tag | `proton-rtsp-11.0-20260609-4` | `GE-Proton11-7` |
| Tag object type | **commit (lightweight tag)** | tag (annotated) |
| Tag ref object | `2faa9d3640bdd0139fc77d52bfd45db6b3807acd` | `4d2eb7396b175821d2a4beed97e3d36da3012bde` |
| Peeled commit | `2faa9d3640bdd0139fc77d52bfd45db6b3807acd` | `c191f35dcebbeccfacd3b4c6f6eea026e588c1c2` |
| Root tree | `9e8983db930052babb6f3ddc850db55de3e03b50` | `9ce007c8526d8c04d0face13dacff1612ff23c8b` |
| Wine gitlink | `fe6a2883bbe62967cd1da5044b7ceaf2c9a43dfe` | `46b29104e3741fe23bf5e2547196a253aab88c89` |

RTSP remains the Wine and media base. GE's Wine gitlink is provenance only.
Its updated DXVK, DXVK-NVAPI, VKD3D-Proton, WineDMO/FFmpeg, Mono, and
game-specific changes do not enter this project merely because the GE patch
source moves to 11-7.

Other GE identities useful for the next pin file:

| Input | Value |
| --- | --- |
| Main Wayland patch directory tree | `b026a03caf61f362559387ba0ea59b4f4a0d6033` (287 patch files) |
| Child-rendering directory tree | `fa298db4d83772e6ab289371f74bb182125998ff` (85 patch files) |
| Launcher blob / SHA-256 | `dc8224e6fa0341b900e6d3e4a75dd0c8588b95df` / `c0fe398829c78c82b26d39c20fbeb6b28d1e46941723962d794d7e5f67d402be` |
| X11 locale tree | `7c8f3ed92d04fc80a139e3204d86650870e21d8f` |

The locale tree is unchanged from GE 11-6, as are libxml2
`b7fa62cbe8ef0df5869e000d5b690bdedd07f33e`, libxkbcommon
`dd642359f8d43c09968e34ca7f1eb1121b2dfd70`, wayland-protocols
`810f1adaf33521cc55fc510566efba2a1418174f`, and Piper
`9d06b74959570772e8bcbe7a3f696664d2421167`.

## RTSP change and source-only control

The RTSP root diff from `-3` to `-4` contains only the Wine gitlink. Wine
advances one commit, `fe6a288`, changing only
`dlls/mfmediaengine/video_frame_sink.c`:

- The video sample queue grows from a fixed two samples to a default of five.
- `WINE_MFME_VIDEO_QUEUE_SIZE` selects a positive size, capped at sixteen.
  Absent or nonpositive values use the default; the setting is read during
  sink creation and retained in a process-global variable.
- Ring-buffer operations and request scheduling use the selected capacity.

This is the upstream rationale for reduced stalls, not a demonstrated
playback improvement in our composition. Increased queue capacity should be
checked for continuity, seek/replacement latency, and A/V synchronization.
Leave the override unset for the first future comparison.

Control actually run: replay all 160 Beta 3 main patches, its exact DDB
cursor patch, and its three local follow-ups onto `fe6a288`. Each patch
passed `git apply --check` before `git am --keep-cr`, with no three-way
fallback or conflict repair. **All 164 applied**, leaving a clean Wine
checkout and tree `9ff7a8e0e8272d815f53635db5b39d0baf75840a`.
This validates source application of the RTSP-only bump, not compilation.

The RTSP release notes also request `steam steam://unlockh264/` on the host.
No such action was performed. Treat that as a separate client prerequisite
to discuss when staging/testing, not a patch or proof about media behavior.

## GE selection review and first failure

Of Beta 3's 160 main selections, 159 filenames remain in GE 11-7 and 158
files are byte-identical. The two changes are:

- `0190-win32u-Reset-variables-to-zero-within-WM_WINE_WINDOW.patch` was
  disabled upstream because initialization was folded into refreshed 0196.
- `0196-winewayland-Implement-focus-changes-through-pGetWind.patch` now
  combines that initialization with its focus handling. Its Win32u context
  expects newer callback/unlock and foreground handling than RTSP provides.

[`beta4-main-selection-review.tsv`](beta4-main-selection-review.tsv) records
169 provisional exact upstream files and SHA-256s: those 159 existing
subjects plus ten new display/input/lifecycle subjects. It is a review list,
not an approved shipping series or a complete dependency closure.

| New main patch | Review scope |
| --- | --- |
| 0286 | Comments **and a behavioral change** from checking `xdg_toplevel` to `xdg_surface`; its short subject understates the diff |
| 0288 | NUL-terminated clipboard class name |
| 0290 | Window placement on output enter/leave, with output reference tracking |
| 0291 | Color-description lifetime, ICC descriptor close, and white-point correction |
| 0292 | Reset size hints only when committed/window states differ |
| 0293 | Require and use `wl_output` version 4; changes compositor requirements |
| 0297 | Move the color-description display flush to the Vulkan caller |
| 0298–0299 | Flash-window helper and activation-token handling |
| 0300 | Separate left/above owner-hint probes |

New 0289 (EVR tests) and 0295–0296 (Vulkan generator changes) are not in
this provisional selection: no dependency from the selected changes has
been established. Their exclusion is not a claim that they are defective.

The GE 11-7 source-only probe applied **111** selections cleanly, then
`git apply --check` failed at selection 112, upstream patch **0196**:

```text
error: patch failed: dlls/win32u/message.c:2243
error: dlls/win32u/message.c: patch does not apply
```

The failed check did not change the tree or leave an `am` conflict. The
pre-failure tree is `ae84e9b016db9e72950cb1e9e4fe2be7cf0b83f3`. Patches
after 0196 were not replayed. There is no final Beta 4 tree/count lock.

Next porting task: adapt 0196's context while preserving RTSP's callback
contract. Compare its effective initialization/focus changes with Beta 3's
0190 plus 0196; do not import unrelated Wine locking changes merely to make
the hunk match. Preserve GE attribution and keep the exact upstream patch
separate from any RTSP-context adapter.

## Follow-up fixes must be reviewed together

GE's preparation order is main Wayland series, SNI, child-rendering, then
`em-fixups`. The release is not just the main directory. In particular:

- `em-fixups/0048` repairs output-reference cleanup and activation-token
  lifetime for the new 0290/0299 behavior, and declares the refresh helper.
  Inspect/adapt the relevant fixes before shipping those new main patches.
  Its existing context includes child-rendering code, so exact application
  to our narrower tree is not established.
- `0017` repairs output-removal locking and lifetime; `0046` improves
  compositor keyboard-layout mapping. They merit bounded portability review
  even though Beta 3 excluded all EM fixups except the DDB cursor patch.
- `0012` handles NULL callback outputs for a newer Win32u unlock contract.
  That newer contract is not present in the RTSP callback inspected here;
  importing it is not automatically required by the 0196 context failure.
- The 85-patch child-rendering subsystem, SNI, Reflex dependencies, and
  GE's overlay-bridge component remain outside the existing composition.
  GE 11-7's launcher/overlay success claims cannot be inherited by this
  selective backport. No low-latency variant is revived.

The exact DDB cursor patch, Steam virtual-controller policy patch,
WineOpenXR decoupling patch, and `wineopenxr/openxr_loader.c` are unchanged
from GE 11-6. Preserve the two local WineWayland VR extension mappings and
the established WineOpenXR/session and Steam Input adapters, verifying them
again after the completed replay.

## Fetch gate and next preparation sequence

`scripts/fetch-sources.sh` and `scripts/apply-patches.sh` currently require
both tags to be annotated. RTSP `-4` is a lightweight tag. Add an explicitly
pinned expected tag type, retaining exact object and peeled-commit checks;
include the type in `scripts/lib/prepared-state.sh`. Keep GE's annotated
check. Do not simply relax both checks to accept any ref. Positive checks
for the two actual types and negative checks for mismatched type/object/commit
belong with that change.

After the context port and dependency review:

1. Finish the source-only replay and verify the complete Wine tree, patch
   counts, WineOpenXR diff, root diff, and required VR/Steam Input symbols.
2. Derive the active Beta 4 pin file from those results. Preserve the older
   patch bundles. Keep the Nix package on published Beta 3 until publication.
3. Introduce `Proton-RTSP-Wayland-GE-Beta4`, display name
   `Proton RTSP Wayland GE Beta 4`, and proposed prefix identity `11.0-105`.
   Update all defaults, launcher/verifier expectations, and source records
   together; do not label incomplete source as prepared.
4. Use fresh `/tmp/proton-rtsp-wayland-ge-beta4-20260609-4` source/state/build
   paths and `ge_on_rtsp/work/beta4-podman-home` for container state. Both
   were absent at this audit. Preserve the shared warm caches and explicit
   workspace lock policy. Fetch remaining submodules only when preparing the
   actual build inputs.
5. Stop for build authorization. Keep `PACKAGE_RELEASE=0`; no build, install,
   package, publication, or host decoder-unlock operation is part of this
   groundwork.

## Retained local evidence

Relative to the workspace root, `ge_on_rtsp/work/beta4-upstreams-20260916/`
contains `rtsp/` (230 MiB), `ge/` (326 MiB), `wine-replay/` (408 MiB), and
`wine-beta3-control/` (405 MiB). Sizes are allocated `du -sh` readings.
The root snapshots were fetched without recursively materializing components.
Wine was fetched at the exact new RTSP commit; both probes are separate
checkouts. The old Beta 3 temporary Wine checkout could not seed a clone
because its referenced `.git/modules/wine` metadata is absent. It was not
repaired or changed.

No Proton compilation, game/Steam execution, installation, prefix access,
publishing, or edits to the separate RTSP-on-GE workspace occurred.
