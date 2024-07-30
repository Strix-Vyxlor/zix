{
  description = "Base nix flake for dev enviroment, uzing zsh";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ self, ... }:
    let 
      supportedSystems = [ "aarch64-linux" "x86_64-linux" ];
      forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor =
        forAllSystems (system: import inputs.nixpkgs { inherit system; });
    in {

      devShells = forAllSystems (system: 
        let 
          pkgs = nixpkgsFor.${system};
          
        in { 
          default = pkgs.mkShell {
            packages = with pkgs; [
              zig
              zls
            ];
        };});

      packages = forAllSystems (system:
        let 
          pkgs = nixpkgsFor.${system};
          package = {
            version = "0.2.0";
            name = "zix";
          #  dev_src = pkgs.fetchFromGitHub{
          #    owner = "Strix-Vyxlor";
          #    repo = "zix";
          #    rev = "master";
          #    hash = "sha256-fC9GqHXO6s2uaCxKAoMv5kNgwoY2srQ7MwDbuaVBhqs=";
          #  };
    
            src = pkgs.fetchzip {
              url = "https://github.com/Strix-Vyxlor/zix/archive/refs/tags/0.2.1.tar.gz";
              hash = "sha256-6x54Rf4KOC3wqg3d2GJz2vpqNg2V0JvPCaz7cdRrPX8=";
            };

            srcPrebuild-x86_64-linux = pkgs.fetchzip {
              url = "https://github.com/Strix-Vyxlor/zix/releases/download/0.1/zix-aarch64-linux.tar.gz";
              hash = "sha256-U7mEspVsejNbiDZgNBV9FtH+0MAL+1zx4Wqbi3BAB/U=";
            };

            srcPrebuild-aarch64-linux = pkgs.fetchzip {
              url = "https://github.com/Strix-Vyxlor/zix/releases/download/0.1/zix-aarch64-linux.tar.gz";
              hash = "sha256-U7mEspVsejNbiDZgNBV9FtH+0MAL+1zx4Wqbi3BAB/U=";
            };
    
          };
        in {
          default = pkgs.stdenv.mkDerivation {
            # package name and src dir
            name = package.name;
            src = package.src;
            version = package.version;

            # build packages
            nativeBuildInputs = with pkgs; [
              zig.hook
            ];

            postPatch = ''
              ln -s ${pkgs.callPackage ./deps.nix { }} $ZIG_GLOBAL_CACHE_DIR/p
            '';

            configurePhase = ''
              mkdir -p $out/
            '';
          };

          prebuild = pkgs.stdenv.mkDerivation {
            name = package.name;
            src = package."srcPrebuild-${system}";
            version = package.version;

            nativeBuildInputs = with pkgs; [ gnutar ];

            installPhase = ''
              mkdir -p $out/bin
              cp zix $out/bin -r
            '';
          };

          #devel = pkgs.stdenv.mkDerivation {
          #  # package name and src dir
          #  name = package.name;
          #  src = package.dev_src;

          #  # build packages
          #  nativeBuildInputs = with pkgs; [
          #    zig.hook
          #  ];

          #  postPatch = ''
            #    ln -s ${pkgs.callPackage ./deps.nix { }} $ZIG_GLOBAL_CACHE_DIR/p
          # '';

          #  configurePhase = ''
          #    mkdir -p $out/
          #  '';
          #};
        }
    );
  };
}
