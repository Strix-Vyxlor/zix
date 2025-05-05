{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types mkIf;
  cfg = config.programs.zix;
in {
  imports = [
    ./overlay.nix
  ];

  options.programs.zix = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        enable zix
      '';
    };
    package = mkOption {
      type = types.package;
      default = pkgs.strix-zix;
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
        default = config.home.homeDirectory + "/.nix-config";
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

    home.file.".config/zix/conf.toml".text = ''
      nix_on_droid = ${
        if cfg.config.nix_on_droid
        then "true"
        else "false"
      }
      flake_path = "${builtins.toString cfg.config.flake_path}"
      hostname = "${cfg.config.hostname}"
      root_command = "${cfg.config.root_command}"
    '';
  };
}
