{
  description = "Nix package for Proton-RTSP-Wayland-GE";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      proton-rtsp-wayland-ge = pkgs.callPackage ./nix/package.nix { };
    in
    {
      packages.${system} = {
        inherit proton-rtsp-wayland-ge;
        default = proton-rtsp-wayland-ge;
      };
    };
}
