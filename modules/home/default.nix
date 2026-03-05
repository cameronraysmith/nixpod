# Home-manager module aggregator
#
# Collects all homeManager modules registered via
# flake.modules.homeManager.* and re-exports them as
# flake.homeModules.default for backward compatibility
# with modules/packages.nix (self.homeModules.default).
{ config, inputs, ... }:
{
  flake.homeModules.default = {
    home.stateVersion = "23.11";
    imports = [
      inputs.catppuccin.homeModules.catppuccin
      inputs.nix-index-database.homeModules.nix-index
    ] ++ (builtins.attrValues config.flake.modules.homeManager);
  };
}
