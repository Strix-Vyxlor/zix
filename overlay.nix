final: prev: {
  strix-zix = final.callPackage ./pkgs/zix.nix {};
  strix-zix-stable = final.callPackage ./pkgs/zix-stable.nix {};
}
