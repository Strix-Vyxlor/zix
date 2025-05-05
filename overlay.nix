{zig-env}: final: prev: let
  env = zig-env.${final.system} {};
in {
  zix = final.callPackage ./pkgs/zix.nix {inherit env;};
  zix-stable = final.callPackage ./pkgs/zix-stable.nix {inherit env;};
}
