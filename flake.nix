{
  description = "Base nix flake for dev enviroment, uzing zsh";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ self, ... }:
    let 
      package = {
        version = "0.1";
        name = "zix";
        dev_src = ./.;
          

        src = ./.;

  

      };

      supportedSystems = [ "aarch64-linux" "x86_64-linux" ];
      forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor =
        forAllSystems (system: import inputs.nixpkgs { inherit system; });
    in {

      devShells = forAllSystems (system: 
        let pkgs = nixpkgsFor.${system};
        in { 
          default = pkgs.mkShell {
            packages = with pkgs; [
              zig
              zls
            ];
        };});

      packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          devel = pkgs.stdenv.mkDerivation {
            # package name and src dir
            name = package.name;
            src = package.dev_src;

            # runtime packages
            buildInputs = with pkgs; [];

            # build packages
            nativeBuildInputs = with pkgs; [
              tar
              gzip
              zig
            ];

            buildPhase = ''
              zig build
            '';

            installPhase = ''
                # install commands here
                mkdir -p $out/bin
                cp bin/zix $out/bin
              '';
          };
        }
    );
  };
}