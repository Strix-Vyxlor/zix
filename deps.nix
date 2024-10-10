# generated by zon2nix (https://github.com/Cloudef/zig2nix)

{ lib, linkFarm, fetchurl, fetchgit, runCommandLocal, zig, name ? "zig-packages" }:

with builtins;
with lib;

let
  unpackZigArtifact = { name, artifact }: runCommandLocal name {
      nativeBuildInputs = [ zig ];
    } ''
      hash="$(zig fetch --global-cache-dir "$TMPDIR" ${artifact})"
      mv "$TMPDIR/p/$hash" "$out"
      chmod 755 "$out"
    '';

  fetchZig = { name, url, hash }: let
    artifact = fetchurl { inherit url hash; };
  in unpackZigArtifact { inherit name artifact; };

  fetchGitZig = { name, url, hash }: let
    parts = splitString "#" url;
    url_base = elemAt parts 0;
    url_without_query = elemAt (splitString "?" url_base) 0;
    rev_base = elemAt parts 1;
    rev = if match "^[a-fA-F0-9]{40}$" rev_base != null then rev_base else "refs/heads/${rev_base}";
  in fetchgit {
    inherit name rev hash;
    url = url_without_query;
    deepClone = false;
  };

  fetchZigArtifact = { name, url, hash }: let
    parts = splitString "://" url;
    proto = elemAt parts 0;
    path = elemAt parts 1;
    fetcher = {
      "git+http" = fetchGitZig { inherit name hash; url = "http://${path}"; };
      "git+https" = fetchGitZig { inherit name hash; url = "https://${path}"; };
      http = fetchZig { inherit name hash; url = "http://${path}"; };
      https = fetchZig { inherit name hash; url = "https://${path}"; };
      file = unpackZigArtifact { inherit name; artifact = /. + path; };
    };
  in fetcher.${proto};
in linkFarm name [
  {
    name = "1220ab73fb7cc11b2308edc3364988e05efcddbcac31b707f55e6216d1b9c0da13f1";
    path = fetchZigArtifact {
      name = "zig-cli";
      url = "https://github.com/sam701/zig-cli/archive/refs/tags/last-zig-0.13.tar.gz";
      hash = "sha256-35gYjyaajsMQhtb+dNNGPXTV1ZY5qw10kUaBWDuDZYo=";
    };
  }
  {
    name = "12205f5e7505c96573f6fc5144592ec38942fb0a326d692f9cddc0c7dd38f9028f29";
    path = fetchZigArtifact {
      name = "known-folders";
      url = "git+https://github.com/ziglibs/known-folders.git#1cceeb70e77dec941a4178160ff6c8d05a74de6f";
      hash = "sha256-jVqUWsSYm84/8XYTHOdWUuz+RyaMO6BvEtOa9lRGJc8=";
    };
  }
  {
    name = "12207ffcc21b74386d241268719cffdd9ac124932f368286fa5deda1e0d230b41a53";
    path = fetchZigArtifact {
      name = "tomlz";
      url = "git+https://github.com/mattyhall/tomlz.git#bb7706fb5a752526f74ce544fc15125be8e58495";
      hash = "sha256-eZ5oyona/IkFuQ7WfP8vsQcvXr+I39scDFk5X0au4Fw=";
    };
  }
]