{zig-env, ...}: {
  nixpkgs.overlays = [
    (import ../overlay.nix {inherit zig-env;})
  ];
}
