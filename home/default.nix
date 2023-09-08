{ self, ... }:
{
  flake = {
    homeModules = {
      default = {
        imports = [
          ./neovim
          ./starship.nix
          ./terminal.nix
        ];
      };
    };
  };
}
