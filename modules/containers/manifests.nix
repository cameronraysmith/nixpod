# Per-arch push packages and multi-arch manifest assembly for container variants
# push-* packages push a single-arch image; *Manifest packages assemble manifest lists
{ self, ... }:
{
  perSystem =
    {
      inputs',
      self',
      pkgs,
      lib,
      system,
      mkPushImage,
      mkManifest,
      ...
    }:
    let
      registry = "ghcr.io";
      githubOrg = "cameronraysmith";

      skopeo-nix2container = inputs'.nix2container.packages.skopeo-nix2container;

      # On darwin, target the corresponding linux system for container images
      targetSystem =
        if pkgs.stdenv.isDarwin then builtins.replaceStrings [ "-darwin" ] [ "-linux" ] system else system;

      getEnvOr =
        var: default:
        let
          val = builtins.getEnv var;
        in
        if val == "" then default else val;

      version = getEnvOr "VERSION" "0.0.0";
      branch = getEnvOr "GITHUB_REF_NAME" "main";

      envTags = [
        (builtins.getEnv "GIT_SHA_SHORT")
        (builtins.getEnv "GIT_SHA")
        (builtins.getEnv "GIT_REF")
      ];

      # Container variant definitions: variant name to package attribute name
      variants = {
        nixpod = "container";
        ghanix = "ghanix";
        codenix = "codenix";
        jupnix = "jupnix";
      };

      pushPackages = lib.mapAttrs' (
        variant: packageName:
        lib.nameValuePair "push-${variant}" (mkPushImage {
          name = variant;
          repo = "${githubOrg}/${variant}";
          image = self.packages.${targetSystem}.${packageName};
          inherit
            registry
            version
            branch
            ;
          tags = envTags;
          skopeo = skopeo-nix2container;
        })
      ) variants;

      manifestPackages = lib.mapAttrs' (
        variant: _:
        lib.nameValuePair "${variant}Manifest" (mkManifest {
          name = variant;
          repo = "${githubOrg}/${variant}";
          inherit
            registry
            version
            branch
            ;
          tags = envTags;
        })
      ) variants;

      pushApps = lib.mapAttrs' (
        variant: _:
        lib.nameValuePair "push-${variant}" {
          type = "app";
          program = "${self'.packages."push-${variant}"}/bin/push-${variant}";
        }
      ) variants;

      manifestApps = lib.mapAttrs' (
        variant: _:
        lib.nameValuePair "${variant}Manifest" {
          type = "app";
          program = "${self'.legacyPackages."${variant}Manifest"}/bin/manifest-${variant}";
        }
      ) variants;
    in
    {
      packages = pushPackages;
      legacyPackages = manifestPackages;
      apps = pushApps // manifestApps;
    };
}
