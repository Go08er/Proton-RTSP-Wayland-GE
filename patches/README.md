<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Patch layout

- `proton-rtsp-wayland.patch` changes the RTSP Proton build wiring and launcher. It enables the native Wine Wayland build, packages xrandr and X11 locale data, preserves RTSP media wiring, and adds the scoped XRizer launch mode.
- `piper-phonemize-pin.patch` replaces Piper's mutable piper-phonemize branch
  URL with the exact commit and SHA-256 used by this release. Piper and this
  modification retain Piper's MIT terms.
- `ge11-wayland-series.txt` is the audited ordered list of 101 Wine patches taken from the pinned GE-Proton11-1 tree.
- `ge11-wayland/` contains those original `git format-patch` files verbatim so
  commit messages, authorship, and LGPL-covered Wine changes travel with the
  project.

`scripts/apply-patches.sh` compares every bundled patch byte-for-byte with the
pinned GE-Proton11-1 checkout before applying it with `git am`. It also verifies
that the resulting Wine history is exactly 101 commits above the pinned RTSP
Wine base.
