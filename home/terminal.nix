{ pkgs, ... }:

# Platform-independent terminal setup
{
  home.packages = with pkgs; [
    # Unix tools
    ripgrep
    fd
    sd
    tree

    # Nix dev
    cachix
    nil
    nix-info
    nixpkgs-fmt

    # Publishing
    asciinema

    # Dev
    gh
    just
    lazygit
    tmate
  ];

  home.shellAliases = rec {
    e = "nvim";
    g = "git";
    lg = "lazygit";
    t = "tree";
  };

  programs = {
    bat.enable = true;
    autojump.enable = false;
    zoxide.enable = true;
    fzf.enable = true;
    jq.enable = true;
    nix-index.enable = true;
    htop.enable = true;

    bash = {
      enable = true;
      initExtra = ''
        # Make Nix and home-manager installed things available in PATH.
        export PATH=/run/current-system/sw/bin/:/nix/var/nix/profiles/default/bin:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:$PATH
      '';
    };

    zsh = {
      enable = true;
      envExtra = ''
        # Make Nix and home-manager installed things available in PATH.
        export PATH=/run/current-system/sw/bin/:/nix/var/nix/profiles/default/bin:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:$PATH
      '';
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
