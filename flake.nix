{
  description = "Base nix flake for dev enviroment, uzing zsh";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
  };

  outputs = inputs@{ self, ... }:
    let 
      system_arch = "x86_64-linux";

      package = {
        name = "package";
        src = "./src";
      };

      shell = "zsh";

      pkgs = import inputs.nixpkgs {
        system = system_arch;
        config = {
          alowUnfree = true;
        };
      };

      shell-configs = {
        zsh = with pkgs; [
          fzf
          zoxide
          zsh
          zsh-z
          nix-zsh-completions
          zsh-f-sy-h
          zsh-fzf-tab
          zsh-autosuggestions
          oh-my-posh
        ];
      };
      
    in {
      devShells."${system_arch}".default = pkgs.mkShell {
        packages = (with pkgs; [
          zig
          zls
        ]) ++ (shell-configs.${shell});

        shellHook = "exec " + shell;
      };

      package.${system_arch}.default = pkgs.stdenv.mkDerivation {
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
    };





}