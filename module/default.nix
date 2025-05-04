{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types mkIf;
  cfg = config.strixvim;
in {
  imports = [
    ./overlay.nix
  ];

  options.zix = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        enable zix
      '';
    };
    package = mkOption {
      type = types.package;
      default = pkgs.zix;
      description = ''
        package to use
      '';
    };
    config = {
      nix_on_droid = mkOption {
        type = types.bool;
        default = false;
        description = ''
          use zix for nix on droid
        '';
      };
      flake_path = mkOption {
        type = types.path;
        default = "~/.nix-config";
        description = ''
          path to nix flake
        '';
      };
      hostname = mkOption {
        type = types.str;
        default = "default";
        description = ''
          hostname defined in flake
        '';
      };
      root_command = mkOption {
        type = types.str;
        default = "sudo";
        description = ''
          command to get root priviliges
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    home.file.".config/zix/conf.toml".text = builtins.toTOML cfg.config;
  };
}
