# zix, a nix helper writen in zig

## instalation
1) clone repo and build, select correct tag for version.
2) add to nix flake, always pull master.
    - install pkgs: stable or default
    - add overlay: strix-zix-stable or strix-zix
    - use module: home manager module auto imports overlay, [module docs](module/README.md)

## configuration
configure zix with a tmol file.
config at `~/.config/zix/conf.toml`:

```toml
nix_on_droid = <bool>
flake_path = <absolute path to flake>
hostname = <hostname defined in config>
root_command = <name of command to get root priviliges eg. sudo or doas>
```
