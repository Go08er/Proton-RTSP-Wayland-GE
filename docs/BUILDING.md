<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Building

The scripts build from pinned upstream revisions in a neutral temporary path.
This avoids embedding a maintainer's home-directory path in binaries and
generated Wine registry data. Beta 1 uses the exact annotated
`GE-Proton11-3` release at peeled commit
`8c8003f7f5473d883fbe1bc7ac070c79955754e8`.

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
/tmp/proton-rtsp-wayland-ge-beta1-11-3
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
/tmp/proton-rtsp-wayland-ge-beta1-11-3/sources/proton-ge-rtsp/build/Proton-RTSP-Wayland-GE-Beta1
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

## Refreshing to a future GE release

Treat every release change as a new source state:

1. Fetch the annotated tag and record both its tag object and peeled commit.
2. Use a new work path, build name, and display name. Advance the prefix
   version only when prefix contents or migration behavior change.
3. Regenerate the selected Wayland bundle from the tagged tree and audit every
   inclusion and exclusion.
4. Copy exact GE patches under new filenames. Re-audit each RTSP layout
   adapter instead of assuming it is still required.
5. Recompute all Git tree, blob, patch, and prepared-diff locks.
6. Run source replay, build, artifact verification, and the complete game
   matrix before changing any release documentation.
7. Keep `PACKAGE_RELEASE=0` until that exact candidate is accepted. Packaging
   and publishing remain separate explicit actions.

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
