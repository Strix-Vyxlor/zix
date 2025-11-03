zig: final: prev: {
  strix-zix = final.callPackage (import ./pkgs/zix.nix zig.${prev.system}."0.15.1") {};
  strix-zix-stable = final.callPackage (import ./pkgs/zix-stable.nix zig.${prev.system}."0.15.1") {};
}
