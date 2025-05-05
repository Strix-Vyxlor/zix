{
  stdenvNoCC,
  zig,
  callPackage,
}:
stdenvNoCC.mkDerivation {
  name = "zix";
  version = "master";
  src = ./. + "/..";
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
