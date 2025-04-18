{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zls = {
      url = "github:zigtools/zls/0.14.0";
      inputs = {
        zig-overlay.follows = "zig-overlay";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        pkgs,
        system,
        ...
      }: let
        zig' = inputs.zig-overlay.packages.${system}.master;
      in {
        devShells.default = pkgs.mkShell.override {inherit (zig') stdenv;} {
          packages = with pkgs; [
            zig'
            inputs.zls.packages.${system}.default

            (symlinkJoin {name = "librsvg"; paths = [librsvg.out librsvg.dev];})
            ghostscript
            glib
            libspectre
            lzo
            pixman
            pkg-config
            poppler
            python3
            xorg.libX11
            xorg.libXext
            xorg.libXrender
            xorg.libxcb
            xorg.xorgproto
          ];
        };
      };
    };
}
