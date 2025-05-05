# zix, a nix helper writen in zig

configure zix with a json file.
config at `~/.config/zix/conf.toml`:

```
nix_on_droid = <bool>
flake_path = <absolute path to flake>
hostname = <hostname defined in config>
root_command = <name of command to get root priviliges eg. sudo or doas>
```
