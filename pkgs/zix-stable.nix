zig: {
  stdenvNoCC,
  fetchzip,
  callPackage,
  ...
}:
stdenvNoCC.mkDerivation {
  name = "zix-stable";
  version = "0.4.0";
  src = fetchzip {
    url = "https://github.com/Strix-Vyxlor/zix/archive/refs/tags/0.4.0.tar.gz";
    hash = "sha256-FUhEZHyZJzaaDzc/uWl7c2aFrqirHAYlVCjH+J4G3Gk=";
  };
  nativeBuildInputs = [zig];
  dontConfigure = true;
  dontInstall = true;
  doCheck = true;
  buildPhase = ''
    mkdir -p .cache
    ln -s ${callPackage ./deps.nix {inherit zig;}} .cache/p
    zig build install --cache-dir $(pwd)/.zig-cache --global-cache-dir $(pwd)/.cache -Dcpu=baseline -Doptimize=ReleaseSafe --prefix $out
  '';
}
