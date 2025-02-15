{
  description = "Base nix flake for dev enviroment, uzing zsh";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {self, ...}: let
    supportedSystems = ["aarch64-linux" "x86_64-linux"];
    forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;

    nixpkgsFor =
      forAllSystems (system: import inputs.nixpkgs {inherit system;});
  in {
    devShells = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          zig
          zls
        ];
      };
    });

    packages = forAllSystems (
      system: let
        pkgs = nixpkgsFor.${system};
        package = {
          version = "0.3.3";
          name = "zix";

          src = pkgs.fetchzip {
            url = "https://github.com/Strix-Vyxlor/zix/archive/refs/tags/0.3.3.tar.gz";
            hash = "sha256-0cwDHs4x92YoEF/Lpj18AiVwD0M+V3yENcjgXxdCmAM=";
          };

          srcPrebuild-x86_64-linux = pkgs.fetchzip {
            url = "https://github.com/Strix-Vyxlor/zix/releases/download/0.3.3/zix-x86_64-linux.tar.gz";
            hash = "sha256-6XZRHkBN0UYcwSpxXvpzghu6F6QZmRnI0CjaoJPtlt0=";
          };

          srcPrebuild-aarch64-linux = pkgs.fetchzip {
            url = "https://github.com/Strix-Vyxlor/zix/releases/download/0.3.3/zix-aarch64-linux.tar.gz";
            hash = "sha256-MDZRTjIfVD/5VoJRLQNdlrkZYHEWKIWc2ai13UYi0Gg=";
          };

          master = pkgs.stdenvNoCC.mkDerivation {
            name = package.name;
            version = "master";
            src = ./.;
            nativeBuildInputs = [pkgs.zig];
            dontConfigure = true;
            dontInstall = true;
            doCheck = true;
            buildPhase = ''
              mkdir -p .cache
              ln -s ${pkgs.callPackage ./deps.nix {zig = pkgs.zig;}} .cache/p
              zig build install --cache-dir $(pwd)/.zig-cache --global-cache-dir $(pwd)/.cache -Dcpu=baseline -Doptimize=ReleaseSafe --prefix $out
            '';
          };
        };
      in {
        zix = package.master;
        default = package.master;

        stable = pkgs.stdenvNoCC.mkDerivation {
          name = package.name;
          version = package.version;
          src = package.src;
          nativeBuildInputs = [pkgs.zig];
          dontConfigure = true;
          dontInstall = true;
          doCheck = true;
          buildPhase = ''
            mkdir -p .cache
            ln -s ${pkgs.callPackage ./deps.nix {zig = pkgs.zig;}} .cache/p
            zig build install --cache-dir $(pwd)/.zig-cache --global-cache-dir $(pwd)/.cache -Dcpu=baseline -Doptimize=ReleaseSafe --prefix $out
          '';
        };

        prebuild = pkgs.stdenvNoCC.mkDerivation {
          name = package.name;
          src = package."srcPrebuild-${system}";
          version = package.version;

          nativeBuildInputs = with pkgs; [gnutar];

          installPhase = ''
            mkdir -p $out/bin
            cp zix $out/bin -r
          '';
        };
      }
    );
  };
}
