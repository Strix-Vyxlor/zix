{
  env,
  fetchzip,
  ...
}: let
  src = fetchzip {
    url = "https://github.com/Strix-Vyxlor/zix/archive/refs/tags/0.3.4.tar.gz";
    hash = "sha256-0cwDHs4x92YoEF/Lpj18AiVwD0M+V3yENcjgXxdCmAM=";
  };
in
  env.package {
    inherit src;
    zigPreferMusl = false;
  }
