{ self, ... }:
{
  perSystem =
    {
      inputs',
      lib,
      system,
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
    in
    {
      legacyPackages = {
        # Combine OCI json for includedSystems and push to registries
        nixpodManifest = inputs'.flocken.legacyPackages.mkDockerManifest {
          github = {
            enable = true;
            enableRegistry = true;
            token = "$GH_TOKEN";
          };
          autoTags = {
            branch = false;
          };
          registries = {
            "ghcr.io" = {
              # enable = lib.mkForce true;
              repo = lib.mkForce "${githubOrg}/nixpod";
              # username = builtins.getEnv "GITHUB_ACTOR";
              # password = "$GH_TOKEN";
            };
          };
          version = builtins.getEnv "VERSION";
          imageFiles = builtins.map (sys: self.packages.${sys}.container) includedSystems;
          tags = [
            (builtins.getEnv "GIT_SHA_SHORT")
            (builtins.getEnv "GIT_SHA")
            (builtins.getEnv "GIT_REF")
          ];
        };

        ghanixManifest = inputs'.flocken.legacyPackages.mkDockerManifest {
          github = {
            enable = true;
            enableRegistry = true;
            token = "$GH_TOKEN";
          };
          autoTags = {
            branch = false;
          };
          registries = {
            "ghcr.io" = {
              repo = lib.mkForce "${githubOrg}/ghanix";
            };
          };
          version = builtins.getEnv "VERSION";
          imageFiles = builtins.map (sys: self.packages.${sys}.ghanix) includedSystems;
          tags = [
            (builtins.getEnv "GIT_SHA_SHORT")
            (builtins.getEnv "GIT_SHA")
            (builtins.getEnv "GIT_REF")
          ];
        };

        codenixManifest = inputs'.flocken.legacyPackages.mkDockerManifest {
          github = {
            enable = true;
            enableRegistry = true;
            token = "$GH_TOKEN";
          };
          autoTags = {
            branch = false;
          };
          registries = {
            "ghcr.io" = {
              repo = lib.mkForce "${githubOrg}/codenix";
            };
          };
          version = builtins.getEnv "VERSION";
          imageFiles = builtins.map (sys: self.packages.${sys}.codenix) includedSystems;
          tags = [
            (builtins.getEnv "GIT_SHA_SHORT")
            (builtins.getEnv "GIT_SHA")
            (builtins.getEnv "GIT_REF")
          ];
        };

        jupnixManifest = inputs'.flocken.legacyPackages.mkDockerManifest {
          github = {
            enable = true;
            enableRegistry = true;
            token = "$GH_TOKEN";
          };
          autoTags = {
            branch = false;
          };
          registries = {
            "ghcr.io" = {
              repo = lib.mkForce "${githubOrg}/jupnix";
            };
          };
          version = builtins.getEnv "VERSION";
          imageFiles = builtins.map (sys: self.packages.${sys}.jupnix) includedSystems;
          tags = [
            (builtins.getEnv "GIT_SHA_SHORT")
            (builtins.getEnv "GIT_SHA")
            (builtins.getEnv "GIT_REF")
          ];
        };
      };
    };
}
