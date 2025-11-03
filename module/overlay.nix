zig: {...}: {
  nixpkgs.overlays = [
    (import ../overlay.nix zig)
  ];
}
