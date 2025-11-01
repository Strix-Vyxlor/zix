inputs: final: prev: {
  zigpkgs = inputs.zig.packages.${prev.system};
  strix-zix = final.callPackage ./pkgs/zix.nix {};
  strix-zix-stable = final.callPackage ./pkgs/zix-stable.nix {};
}
