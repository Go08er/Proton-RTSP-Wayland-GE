# SPDX-License-Identifier: BSD-3-Clause

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [
    bash
    binutils
    coreutils
    curl
    diffutils
    file
    findutils
    git
    gawk
    gnumake
    gnupatch
    gnugrep
    gnused
    gnutar
    gzip
    jq
    patchelf
    pkg-config
    podman
    python3
    ripgrep
    rsync
    tree
    unzip
    util-linux
    vulkan-tools
    which
    zstd
    pkgsCross.mingw32.stdenv.cc
    pkgsCross.mingwW64.stdenv.cc
  ];
}
