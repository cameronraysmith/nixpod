{ inputs, self, ... }:
{
  perSystem =
    {
      ...
    }:
    {
      nix-unit.inputs = {
        inherit (inputs)
          nixpkgs
          flake-parts
          home-manager
          nix2container
          catppuccin
          import-tree
          treefmt-nix
          git-hooks
          sops-nix
          nix-index-database
          nix-unit
          systems
          ;
        inherit self;
      };

      nix-unit.tests = {
        # TC-N01: Flake output existence
        # Smoke test that the flake evaluates and produces expected top-level outputs
        testFlakeOutputsExist = {
          expr =
            (builtins.hasAttr "packages" self)
            && (builtins.hasAttr "legacyPackages" self)
            && (builtins.hasAttr "homeModules" self)
            && (builtins.hasAttr "apps" self);
          expected = true;
        };

        # TC-N02: Container matrix completeness
        # The containerMatrix is consumed by CI for dynamic matrix discovery
        testContainerMatrixVariants = {
          expr = builtins.sort builtins.lessThan (
            builtins.attrNames self.legacyPackages.x86_64-linux.containerMatrix
          );
          expected = [
            "codenix"
            "ghanix"
            "jupnix"
            "nixpod"
          ];
        };

        # TC-N03: Container matrix entry structure
        # CI depends on the shape of each matrix entry having name, package, and system fields
        testContainerMatrixStructure = {
          expr = builtins.all (
            name:
            let
              entry = self.legacyPackages.x86_64-linux.containerMatrix.${name};
            in
            builtins.hasAttr "name" entry && builtins.hasAttr "package" entry && builtins.hasAttr "system" entry
          ) (builtins.attrNames self.legacyPackages.x86_64-linux.containerMatrix);
          expected = true;
        };

        # TC-N04: Home configurations exist for all container users
        # Container variants reference specific user home configurations
        testHomeConfigurationsExist = {
          expr = builtins.sort builtins.lessThan (
            builtins.attrNames self.legacyPackages.x86_64-linux.homeConfigurations
          );
          expected = [
            "jovyan"
            "root"
            "runner"
          ];
        };

        # TC-N05: Container variants reference valid package attributes
        # Cross-reference validation between matrix and packages
        testContainerPackagesExist = {
          expr = builtins.all (name: builtins.hasAttr name self.packages.x86_64-linux) (
            builtins.attrNames self.legacyPackages.x86_64-linux.containerMatrix
          );
          expected = true;
        };

        # TC-N06: Container loader packages exist for all variants
        testContainerLoadersExist = {
          expr = builtins.all (name: builtins.hasAttr "load-${name}" self.packages.x86_64-linux) [
            "nixpod"
            "ghanix"
            "codenix"
            "jupnix"
          ];
          expected = true;
        };

        # TC-N07: Push packages exist for all variants
        testPushPackagesExist = {
          expr = builtins.all (name: builtins.hasAttr "push-${name}" self.packages.x86_64-linux) [
            "nixpod"
            "ghanix"
            "codenix"
            "jupnix"
          ];
          expected = true;
        };

        # TC-N08: Manifest apps exist for all variants
        testManifestAppsExist = {
          expr = builtins.all (name: builtins.hasAttr "${name}Manifest" self.apps.x86_64-linux) [
            "nixpod"
            "ghanix"
            "codenix"
            "jupnix"
          ];
          expected = true;
        };

        # TC-N09: Home modules aggregation
        # modules/packages.nix references self.homeModules.default
        testHomeModulesDefaultExists = {
          expr = builtins.hasAttr "default" self.homeModules;
          expected = true;
        };

        # TC-N10: S6 overlay package exists
        testS6OverlayExists = {
          expr = builtins.hasAttr "s6-overlay-layer" self.packages.x86_64-linux;
          expected = true;
        };

        # TC-N11: Nixpod users package exists
        testNixpodUsersExists = {
          expr = builtins.hasAttr "nixpod-users" self.packages.x86_64-linux;
          expected = true;
        };
      };
    };
}
