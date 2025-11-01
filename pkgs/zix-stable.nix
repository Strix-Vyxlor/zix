{
  stdenvNoCC,
  fetchzip,
  zigpkgs,
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
  nativeBuildInputs = [zigpkgs."0.15.1"];
  dontConfigure = true;
  dontInstall = true;
  doCheck = true;
  buildPhase = ''
    mkdir -p .cache
    ln -s ${callPackage ./deps.nix {zig = zigpkgs."0.15.1";}} .cache/p
    zig build install --cache-dir $(pwd)/.zig-cache --global-cache-dir $(pwd)/.cache -Dcpu=baseline -Doptimize=ReleaseSafe --prefix $out
  '';
}
