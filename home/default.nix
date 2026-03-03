{ self, inputs, ... }:
{
  flake = {
    homeModules = {
      default = {
        # See https://home-manager-options.extranix.com/ for home-manager
        # options used inside these imported modules.
        home.stateVersion = "23.11";
        imports = [
          inputs.catppuccin.homeModules.catppuccin
          inputs.nix-index-database.homeModules.nix-index
          ./atuin.nix
          ./neovim
          ./git.nix
          ./starship.nix
          ./terminal.nix
          ./zsh.nix
        ];
      };
    };
  };
}
