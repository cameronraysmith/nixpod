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
    autojump.enable = false;
    bat.enable = true;
    fzf.enable = true;
    git.enable = true;
    htop.enable = true;
    jq.enable = true;
    nix-index.enable = true;
    zoxide.enable = true;

    bash = {
      enable = true;
      initExtra = ''
        # Ensure all nix and home-manager installed files are available in PATH.
        export PATH=/run/current-system/sw/bin/:/nix/var/nix/profiles/default/bin:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:$PATH
      '';
    };

    zsh = {
      enable = true;
      envExtra = ''
        # Ensure all nix and home-manager installed files are available in PATH.
        export PATH=/run/current-system/sw/bin/:/nix/var/nix/profiles/default/bin:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:$PATH
      '';
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
