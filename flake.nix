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
            version = "0.1";
            name = "zix";
            dev_src = pkgs.fetchFromGitHub{
              owner = "Strix-Vyxlor";
              repo = "zix";
              rev = "master";
              hash = "sha256-1j7fVVqpXl9Fp6Qn5u08sbmdy8JcTL3V0VCrLAwNitQ=";
            };
    
            src = ./.;
    
          };
        in {
          devel = pkgs.stdenv.mkDerivation {
            # package name and src dir
            name = package.name;
            src = package.dev_src;

            # runtime packages
            buildInputs = with pkgs; [];

            configurePhase = ''
              pwd
              mkdir -p $out
            '';

            buildPhase  = ''
              pwd
              zig build
            '';

            installPhase = ''
              mkdir -p $out/bin
              cp zig-out/bin/* $out/bin
            '';

            # build packages
            nativeBuildInputs = with pkgs; [
              zig
            ];
          };
        }
    );
  };
}