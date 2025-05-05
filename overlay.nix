final: prev: {
  zix = final.callPackage ./pkgs/zix.nix {};
  zix-stable = final.callPackage ./pkgs/zix-stable.nix {};
}
