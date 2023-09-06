# https://nix-community.github.io/home-manager/index.html#sec-usage-configuration
{ pkgs, ... }: {
  imports = [
    # This loads ./home/neovim/default.nix - neovim configured for Haskell dev, and other things.
    ./home/neovim
    ./home/starship.nix
  ];

  # Nix packages to install to $HOME
  #
  # Search for packages here: https://search.nixos.org/packages
  home.packages = with pkgs; [
    tmate
    nix-info
    cachix
    lazygit # Better git UI
    ripgrep # Better `grep`
    nil # Nix language server
    nixci
  ];

  # Programs natively supported by home-manager.
  programs = {
    # on macOS, you probably don't need this
    bash = {
      enable = true;
      initExtra = ''
        # Make Nix and home-manager installed things available in PATH.
        export PATH=/run/current-system/sw/bin/:/nix/var/nix/profiles/default/bin:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:$PATH
      '';
    };

    # For macOS's default shell.
    zsh = {
      enable = true;
      envExtra = ''
        # Make Nix and home-manager installed things available in PATH.
        export PATH=/run/current-system/sw/bin/:/nix/var/nix/profiles/default/bin:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:$PATH
      '';
    };

    # https://zero-to-flakes.com/direnv
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # Type `z <pat>` to cd to some directory
    zoxide.enable = true;
  };
}
