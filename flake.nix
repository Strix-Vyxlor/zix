{
  description = "Base nix flake for dev enviroment, uzing zsh";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ self, ... }:
    let 
      package = {
        name = "zix";
        src = ".";
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

      package = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          default = pkgs.stdenv.mkDerivation {
            # package name and src dir
            pname = package.name;
            src = package.src;

            # runtime packages
            buildInputs = with pkgs; [];

            # build packages
            nativeBuildInputs = with pkgs; [
              zig
            ];


            buildPhase = ''
                # put build commands here
              '';

            installPhase = ''
                # install commands here
              '';

            postFixup = ''
              # put wrapper command here;
            '';
          };
        }
    );
  };
}