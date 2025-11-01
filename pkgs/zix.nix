{
  stdenvNoCC,
  zigpkgs,
  callPackage,
}:
stdenvNoCC.mkDerivation {
  name = "zix";
  version = "master";
  src = ./. + "/..";
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
