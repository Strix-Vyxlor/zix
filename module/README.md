# zix module docs
*Note: defaults given*

```nix
programs.zix = {
    enable = false; # enable zix
    package = pkgs.strix-zix; # the zix package to install
    config = {
        nix_on_droid = false; # enable zix for nix-on-droid
        flake_path = config.home.homeDirectory + "/.nix-config"; # default nix system flake path is $HOME/.nix-config
        hostname = "default" # the hostname defined in nixosConfigurations
        root_command = "sudo" # the command that gives super user priviliges 
    };
};
```
