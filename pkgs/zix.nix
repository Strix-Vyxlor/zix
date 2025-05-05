{env}:
env.package {
  src = env.pkgs.lib.cleanSource (./. + "/..");
  zigPreferMusl = false;
  zigBuildZon = ./. + "/../build.zig.zon";
  zigBuildZonLock = ./. + "/../build.zig.zon2json-lock";
}
