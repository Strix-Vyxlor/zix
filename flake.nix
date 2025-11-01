{
  description = "Base nix flake for dev enviroment, uzing zsh";

  outputs = inputs @ {self, ...}: let
    zix-overlay = import ./overlay.nix inputs;
    systems = builtins.attrNames inputs.zig.packages;
  in
    inputs.flake-utils.lib.eachSystem systems (system: let
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
          zigpkgs."0.15.1"
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

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zig.url = "github:mitchellh/zig-overlay";
  };
}
