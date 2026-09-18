<!-- SPDX-License-Identifier: BSD-3-Clause -->

# GE-Proton11-7 selection for Beta 4

Input: annotated tag object `4d2eb7396b175821d2a4beed97e3d36da3012bde`,
commit `c191f35dcebbeccfacd3b4c6f6eea026e588c1c2`.
RTSP Wine remains `fe6a2883bbe62967cd1da5044b7ceaf2c9a43dfe`;
GE Wine is never substituted.

The replay contains **176 Wine commits**:

- 169 main selections listed with exact upstream hashes in
  [the selection manifest](../docs/beta4-main-selection-review.tsv).
  168 apply unchanged. Exact upstream 0196 is preserved in the bundle, but
  its context-only RTSP adapter is applied instead.
- Three EM follow-ups, in [replay order](ge-proton11-7-followups.tsv):
  0017 output-removal locking/lifetime, 0046 compositor keyboard layout,
  and 0048 output/activation-token lifetime. 0017 and 0046 apply unchanged;
  0048 has a context-only RTSP adapter and its original is retained.
- The unchanged exact GE DDB cursor patch (its 11-6 filename records its
  intake, not a different source; it is byte-identical in 11-7).
- The existing Winebus and SetupAPI Steam Input adapters and the two-line
  WineWayland OpenVR/OpenXR extension repair.

Thus **173 GE-derived selections** comprise 171 exact applications plus
two context adapters; the three established local follow-ups make 176.
WineOpenXR and launcher changes are separate and are not counted as Wine commits.
Final Wine tree: `0c7b3be3791ce1a4f5e53e2655b31d72cabcd3f6`.

## Why these adapters and follow-ups

0196 keeps GE's initialization and focus changes, without importing the
newer Win32u unlock callback or foreground setter used only as hunk context.
0048 keeps RTSP's inline input cleanup and adds GE's output cleanup after
the existing role cleanup; its header context excludes child-only helpers.
`tests/preparation-gates.sh` compares every added/removed line of each
adapter against its upstream original. Both retain those lines in order.
This is source equivalence of the changes, not runtime qualification.

New main 0290 and 0299 introduce output references and activation tokens.
0048 fixes their cleanup and token ownership, including stale-surface events,
duplicate references, destruction without leave events, and allocation failure.
0017 resolves the existing output-removal double lock and wrong-pointer
release; it directly interacts with that output-reference lifecycle.
0046 is a standalone native-Wayland keyboard fix: it uses the compositor's
Latin-letter arrangement and active layout instead of assuming a language's
default layout. Non-Latin/ambiguous tables retain the upstream fallback.

Compared with Beta 3, 0190 is absent because its initialization was folded
into 0196. The ten new main selections are explained in the manifest.
In particular 0286 changes a surface-role predicate despite its “comments”
subject, and 0293 requires `wl_output` version 4.

## Excluded

The separate 85-patch child-rendering subsystem, SNI, Reflex and overlay
bridge remain excluded. Main 0289 EVR tests and 0295–0296 Vulkan generator
changes have no established dependency in this selection. EM 0012's NULL
output guard serves a newer Win32u unlock callback that RTSP does not invoke.
Other EM patches are not silently included.

All RTSP component gitlinks stay at the RTSP release values. Its -4 update
changes only Wine's media-engine video queue (default five, configurable to
sixteen), not DXVK, FFmpeg or GStreamer. Leave that queue override unset
for the first future comparison. No build or playback result is implied.
