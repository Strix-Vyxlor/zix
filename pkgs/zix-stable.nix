{
  stdenvNoCC,
  fetchzip,
  zig,
  callPackage,
  ...
}:
stdenvNoCC.mkDerivation {
  name = "zix-stable";
  version = "0.3.4";
  src = fetchzip {
    url = "https://github.com/Strix-Vyxlor/zix/archive/refs/tags/0.3.4.tar.gz";
    hash = "sha256-1WdmjCdgN7yK4vwUYVvOaZMkI5+pKC8i/c7UDx8INP4=";
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
