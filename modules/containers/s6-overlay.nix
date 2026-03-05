# Fetch and extract s6-overlay tarballs into a single derivation.
#
# Produces a store path containing the s6-overlay filesystem layout
# (/init, /command/, /etc/s6-overlay/, /package/) ready for inclusion
# as a container layer.
{ ... }:
{
  perSystem =
    {
      pkgs,
      lib,
      system,
      ...
    }:
    {
      packages = lib.mkIf pkgs.stdenv.isLinux {
        s6-overlay-layer =
          let
            version = "v3.2.0.0";

            archMap = {
              "x86_64-linux" = {
                arch = "x86_64";
                hash = "sha256-rZgqgBvXJ1fHsbU1OaFGz3FeZAtNjwpqZxo9G1YP4eI=";
              };
              "aarch64-linux" = {
                arch = "aarch64";
                hash = "sha256-holz6YIQJXu6cl/1sXqgkgCMmo5RdEmeOLphGo/H5HM=";
              };
            };

            archInfo =
              archMap.${system}
                or (throw "s6-overlay: unsupported system '${system}', expected one of: ${lib.concatStringsSep ", " (lib.attrNames archMap)}");

            noarchTarball = pkgs.fetchurl {
              url = "https://github.com/just-containers/s6-overlay/releases/download/${version}/s6-overlay-noarch.tar.xz";
              hash = "sha256-SwwJB+Z2KBTDGFDg5sZ2LDhVcdRlbrhyWFKwsVhnE7Y=";
            };

            archTarball = pkgs.fetchurl {
              url = "https://github.com/just-containers/s6-overlay/releases/download/${version}/s6-overlay-${archInfo.arch}.tar.xz";
              hash = archInfo.hash;
            };
          in
          pkgs.runCommand "s6-overlay-${version}"
            {
              nativeBuildInputs = [
                pkgs.gnutar
                pkgs.xz
              ];
            }
            ''
              mkdir -p $out
              tar -C $out --no-same-permissions -Jxf ${noarchTarball}
              tar -C $out --no-same-permissions -Jxf ${archTarball}
            '';
      };
    };
}
