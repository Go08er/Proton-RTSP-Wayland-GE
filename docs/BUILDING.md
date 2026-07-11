<!-- SPDX-License-Identifier: BSD-3-Clause -->

# Building

The scripts build from pinned upstream revisions in a neutral temporary path. This avoids embedding a maintainer's home-directory path in binaries and generated Wine registry data.

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

The build defaults to `JOBS=2`. Increase it only after checking available RAM and
swap. For an 8-core/16-thread machine with roughly 30 GiB of RAM, `JOBS=4` to
`JOBS=6` is a reasonable starting range:

```sh
JOBS=6 ./scripts/build.sh
```

`JOBS` is passed to the outer GNU Make build and to Ninja component builds.
Several components or architectures can overlap, so it is not a strict
system-wide process cap. Start conservatively and watch memory, swap, load, and
thermal limits rather than setting it directly to the CPU thread count.

The default work directory is:

```text
/tmp/proton-rtsp-wayland-ge-work
```

Override it consistently for all three commands when required:

```sh
WORK_ROOT=/tmp/custom-neutral-path ./scripts/fetch-sources.sh
WORK_ROOT=/tmp/custom-neutral-path ./scripts/apply-patches.sh
WORK_ROOT=/tmp/custom-neutral-path JOBS=6 ./scripts/build.sh
```

The release workflow writes both the binary archive and a companion prepared
source archive to `dist/`, with a SHA-512 checksum for each. The source package
includes the applied Proton/Wine trees, original GE format-patch files, Xalia
source, speech-stack external snapshots, and any Cargo source caches supplied
through `CARGO_REGISTRY_SRC` and `CARGO_GIT_CHECKOUTS`.

Build products and fetched source trees are excluded from version control.

## Reproducibility and release hygiene

The scripts pin the RTSP, GE, Wine, Xalia, piper-phonemize, dependency, and
xrandr revisions. Container images, `<nixpkgs>`, toolchains, and archive mtimes
can still change unless the builder pins them separately. The result is
source-reconstructable, not currently guaranteed to be bit-identical.

Before distributing a binary:

1. Build from a neutral path without a user name.
2. Run `scripts/verify.sh` on the resulting compatibility-tool directory.
3. Verify `licenses/manifest.sha256` inside the compatibility tool.
4. Inspect archive ownership with `tar -tvf`.
5. Confirm both checksum files contain only their archive basenames.
6. Keep the binary and corresponding-source archives available together.
7. Review the component licenses and bundled notices.
8. Test both default and opt-in modes on a disposable or backed-up prefix.
