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
            version = "0.2.3";
            name = "zix";
          #  dev_src = pkgs.fetchFromGitHub{
          #    owner = "Strix-Vyxlor";
          #    repo = "zix";
          #    rev = "master";
          #    hash = "sha256-fC9GqHXO6s2uaCxKAoMv5kNgwoY2srQ7MwDbuaVBhqs=";
          #  };
    
            src = pkgs.fetchzip {
              url = "https://github.com/Strix-Vyxlor/zix/archive/refs/tags/0.2.3.tar.gz";
              hash = "sha256-uQjMHRqFK+7s90ezHW41zKD0xfwC8UvsPmcVbXZUOag=";
            };

            srcPrebuild-x86_64-linux = pkgs.fetchzip {
              url = "https://github.com/Strix-Vyxlor/zix/releases/download/0.2.3/zix-x86_64-linux.tar.gz";
              hash = "sha256-kuiaED9f9VHXZLkathcdNEf0dr1mKbUgTrgjfjkM7Js=";
            };

            srcPrebuild-aarch64-linux = pkgs.fetchzip {
              url = "https://github.com/Strix-Vyxlor/zix/releases/download/0.2.3/zix-aarch64-linux.tar.gz";
              hash = "sha256-64gDuBtclRu2z3eYeI89hjPPzsmr0Oz5j97rQnQj2Iw=";
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
