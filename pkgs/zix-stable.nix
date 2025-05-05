{
  env,
  fetchzip,
  ...
}: let
  src = fetchzip {
    url = "https://github.com/Strix-Vyxlor/zix/archive/refs/tags/0.3.4.tar.gz";
    hash = "sha256-1WdmjCdgN7yK4vwUYVvOaZMkI5+pKC8i/c7UDx8INP4=";
  };
in
  env.package {
    inherit src;
    zigPreferMusl = false;
  }
