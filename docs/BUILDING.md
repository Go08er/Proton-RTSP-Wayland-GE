<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Building

The scripts build from pinned upstream revisions in a neutral temporary path.
This avoids embedding a maintainer's home-directory path in binaries and
generated Wine registry data. Alpha 2 uses Proton-GE commit
`9fad3bbe270409e67a8d2f4d123afc73d848306a`, selected from `master` on
2026-07-13. This is a development snapshot, not GE-Proton11-2.

## Requirements

- Git, Bash, Python 3, GNU Make, rsync, tar, sha256sum, sha512sum, and ripgrep
- A working Podman or Docker installation
- Enough free space for Proton's source, container image, and build products
- The compiler and container prerequisites expected by the upstream RTSP Proton build

Configure container-image trust according to your operating system and security policy. These scripts do not create an `insecureAcceptAnything` container signature policy.

## Build sequence

From the repository root:

```sh
./scripts/fetch-sources.sh
./scripts/apply-patches.sh
./scripts/build.sh
```

Both fetch and preparation clear the prior `.prepared` state before doing any
work. Preparation writes a new state only after all patches and dependency
checks succeed. The build compares that state byte-for-byte against the exact
pins and canonical RTSP/GE source paths, then rechecks the deterministic Wine
tree. A failed or interrupted preparation therefore cannot authorize a build.

The build defaults to `JOBS=1`. `scripts/build.sh` also re-executes itself with
`nice -n 19` and, when available, idle-class `ionice` so the preparation build
has low CPU and I/O scheduling priority. Keep the single-job default while the
machine is in use:

```sh
JOBS=1 ./scripts/build.sh
```

`JOBS` is a global nested-worker budget. The wrapper divides it between GNU
Make's component/architecture orchestration and each component's Ninja build,
and rejects a decomposition whose product exceeds the budget. For example,
`JOBS=6` defaults to three outer recipes with two Ninja workers apiece instead
of allowing six outer recipes to each start six Ninja workers. Recursive GNU
Make builds remain governed by the outer jobserver.

Advanced local testing can set `ORCHESTRATOR_JOBS` and `COMPONENT_JOBS`
explicitly, but their product must not exceed `JOBS`. Both Proton project
wrappers also take the same workspace build lock, so the two experimental
distributions cannot compile concurrently by accident.

Interrupted builds can leave downloaded Gecko, Mono, Xalia, and xrandr inputs
in the source tree's untracked `contrib/` cache. Resume validation accepts only
the five pinned archive names and verifies every present file by SHA-256;
unknown files, symlinks, subdirectories, or changed content fail closed.

The Rust `gst-plugin-dav1d` targets use `--remap-path-prefix` for `CARGO_HOME`.
Rust retains source locations in release panic diagnostics, so debug stripping
alone cannot remove a personal Cargo checkout path. The artifact verifier walks
every regular file, including hidden and normally ignored names, and scans raw
bytes plus ASCII paths embedded in UTF-16. It fails on the exact builder home or
an absolute Unix/Windows user path. The only generic-path exceptions are
Proton's standard Windows `steamuser` and `Public` profiles and immutable
upstream diagnostics rooted at `/home/runner/work/llvm-mingw/`; arbitrary files
are never excluded from scanning.

The default work directory is:

```text
/tmp/proton-rtsp-wayland-ge-work
```

Keep custom work paths similarly short. The pinned eSpeak NG phoneme compiler
uses a fixed-size path buffer; `scripts/build.sh` fails before configuration if
the longest known Piper phoneme path would exceed its 274-character limit.
This also avoids wasting a long build only to discover path truncation later.

Override it consistently for all three commands when required:

```sh
WORK_ROOT=/tmp/custom-neutral-path ./scripts/fetch-sources.sh
WORK_ROOT=/tmp/custom-neutral-path ./scripts/apply-patches.sh
WORK_ROOT=/tmp/custom-neutral-path JOBS=1 ./scripts/build.sh
```

The default is `PACKAGE_RELEASE=0`. It builds and verifies the compatibility
tool at:

```text
/tmp/proton-rtsp-wayland-ge-work/sources/proton-ge-rtsp/build/Proton-RTSP-Wayland-GE-Alpha2
```

It does not create release archives, push commits, publish a GitHub release, or
upload anything. Keep that default through source review and game testing.

Only after the exact build has been accepted for distribution, explicitly run:

```sh
PACKAGE_RELEASE=1 JOBS=1 ./scripts/build.sh
```

That local packaging mode writes both the binary archive and a companion
prepared-source archive to `dist/`, with a SHA-512 checksum for each. The
source package includes the applied Proton/Wine trees, original GE format-patch
files, Xalia source, speech-stack external snapshots, and optional Cargo
registry-source or Git-checkout directories explicitly supplied through
`CARGO_REGISTRY_SRC` and `CARGO_GIT_CHECKOUTS`. The distribution project must
be clean: only tracked files from its current revision are exported, while
ignored workspace data is never considered package input.
The Xalia binary ZIP is SHA-256 checked immediately after download, again
before extraction, and again before it enters the corresponding-source archive.

Build products and fetched source trees are excluded from version control.

## Switching the pin to GE-Proton11-2

Do not treat the current `master` snapshot as an 11-2 release. When the
`GE-Proton11-2` tag is published, make the swap as a new, reviewable source
update:

1. Fetch the release tag in a clean Proton-GE checkout and record the peeled
   commit returned by `git rev-parse 'GE-Proton11-2^{commit}'`.
2. In `config/upstream-pins.sh`, replace `GE_COMMIT` with that exact commit,
   set `GE_SOURCE_KIND="release"`, and set
   `GE_SOURCE_LABEL="GE-Proton11-2"`.
3. Regenerate the GE Wayland patch bundle from the exact tagged tree. Update
   `GE_WAYLAND_PATCH_DIR` and `GE_WAYLAND_PATCH_COUNT`; do not reuse the
   current snapshot bundle without proving every file is identical.
4. Copy the tag's exact
   `patches/wineopenxr/wineopenxr_decouple.patch` into a newly named local
   bundle and update `GE_WINEOPENXR_PATCH`. Do not merely change the commit pin
   while retaining the development-snapshot repair. Re-audit the separate
   RTSP makedep adapter against that patch; keep it only if the tag still adds
   the conflicting `UNIX_LIBS` assignment.
5. Update the documented commit, source label, patch count, and provenance.
   Use a fresh `WORK_ROOT`, then rerun fetch, patch replay, the single-threaded
   build, `scripts/verify.sh`, and the source/privacy audits.
6. Repeat the complete game matrix: default X11/XWayland, native Wayland,
   64-bit and 32-bit D3D11, RTSP/media playback, XR in `auto`, and the scoped
   `xrizer` fallback.
7. Leave `PACKAGE_RELEASE=0` until that exact tagged build has passed review.
   Packaging is local only; publishing remains a separate, explicit decision.

## Reproducibility and release hygiene

The scripts pin the RTSP, GE, Wine, Xalia, piper-phonemize, dependency, and
xrandr revisions. The libxml2, libxkbcommon, and Wayland Protocols pins must
also match gitlinks in the exact GE root tree before they are used. Container
images, `<nixpkgs>`, toolchains, and archive mtimes can still change unless the
builder pins them separately. The result is source-reconstructable, not
currently guaranteed to be bit-identical.

Before distributing a binary:

1. Build from a neutral path without a user name.
2. Run `scripts/verify.sh` on the resulting compatibility-tool directory.
3. Verify `licenses/manifest.sha256` inside the compatibility tool.
4. Inspect archive ownership with `tar -tvf`.
5. Confirm both checksum files contain only their archive basenames.
6. Keep the binary and corresponding-source archives available together.
7. Review the component licenses and bundled notices.
8. Test both default and opt-in modes on a disposable or backed-up prefix.
