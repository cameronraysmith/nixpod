{ self, ... }:
{
  perSystem =
    {
      inputs',
      pkgs,
      lib,
      system,
      mkMultiArchManifest,
      ...
    }:
    let
      githubOrg = "cameronraysmith";
      includedSystems =
        let
          envVar = builtins.getEnv "NIX_IMAGE_SYSTEMS";
        in
        if envVar == "" then
          [
            "x86_64-linux"
            "aarch64-linux"
          ]
        else
          builtins.filter (sys: sys != "") (builtins.split " " envVar);

      skopeo-nix2container = inputs'.nix2container.packages.skopeo-nix2container;

      getEnvOr =
        var: default:
        let
          val = builtins.getEnv var;
        in
        if val == "" then default else val;

      mkManifest =
        { name, packageName }:
        mkMultiArchManifest {
          inherit name;
          images = lib.listToAttrs (
            map (sys: lib.nameValuePair sys self.packages.${sys}.${packageName}) includedSystems
          );
          registry = {
            name = "ghcr.io";
            repo = "${githubOrg}/${name}";
            username = getEnvOr "GITHUB_ACTOR" "cameronraysmith";
            password = "$GITHUB_TOKEN";
          };
          version = getEnvOr "VERSION" "0.0.0";
          tags = [
            (builtins.getEnv "GIT_SHA_SHORT")
            (builtins.getEnv "GIT_SHA")
            (builtins.getEnv "GIT_REF")
          ];
          branch = getEnvOr "GITHUB_REF_NAME" "main";
          skopeo = skopeo-nix2container;
        };
    in
    {
      legacyPackages = {
        nixpodManifest = mkManifest {
          name = "nixpod";
          packageName = "container";
        };

        ghanixManifest = mkManifest {
          name = "ghanix";
          packageName = "ghanix";
        };

        codenixManifest = mkManifest {
          name = "codenix";
          packageName = "codenix";
        };

        jupnixManifest = mkManifest {
          name = "jupnix";
          packageName = "jupnix";
        };
      };
    };
}
