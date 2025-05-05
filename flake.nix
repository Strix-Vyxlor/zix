{
  description = "Base nix flake for dev enviroment, uzing zsh";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zig2nix.url = "github:Cloudef/zig2nix";
  };

  outputs = inputs @ {self, ...}: let
    zix-overlay = import ./overlay.nix {inherit (inputs.zig2nix.outputs) zig-env;};
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
        zix = pkgs.zix;
        zix-stable = pkgs.zix-stable;
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
        zix = import ./module {inherit (inputs.zig2nix.outputs) zig-env;};
        default = zix;
      };

      overlays = rec {
        default = zix;
        zix = zix-overlay;
      };
    };
}
