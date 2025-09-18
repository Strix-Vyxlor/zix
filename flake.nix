{
  description = "Base nix flake for dev enviroment, uzing zsh";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs @ {self, ...}: let
    zix-overlay = import ./overlay.nix;
  in
    inputs.flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          zix-overlay
        ];
      };
    in {
      packages = rec {
        default = zix;
        stable = zix-stable;
        zix = pkgs.strix-zix;
        zix-stable = pkgs.strix-zix-stable;
      };
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          zig
          zls
        ];
      };
    })
    // {
      homeManagerModules = rec {
        zix = ./module;
        default = zix;
      };

      overlays = rec {
        default = zix;
        zix = zix-overlay;
      };
    };
}
