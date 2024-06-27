{ pkgs, ... }:
# Platform-independent terminal setup
{
  home.packages = with pkgs; [
    # Unix tools
    ripgrep
    fd
    gawk
    gnused
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
    kubectl
    (pkgs.nerdfonts.override { fonts = [ "Inconsolata" ]; })
    tmate
    vim
  ];

  home.shellAliases = rec {
    e = "nvim";
    g = "git";
    k = "kubectl";
    lg = "lazygit";
    t = "tree";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  i18n = {
    glibcLocales = pkgs.glibcLocales.override {
      allLocales = false;
      locales = [ "en_US.UTF-8/UTF-8" ];
    };
  };

  fonts.fontconfig.enable = true;
  catppuccin.flavor = "mocha";
  catppuccin.enable = true;

  programs = {
    autojump.enable = false;
    bat.enable = true;
    btop.enable = true;
    fzf.enable = true;
    htop.enable = true;
    jq.enable = true;
    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
    nix-index-database.comma.enable = true;
    zoxide.enable = true;

    bash = {
      enable = true;
      initExtra = ''
        # Ensure all nix and home-manager installed files are available in PATH.
        export PATH=/run/current-system/sw/bin/:/nix/var/nix/profiles/default/bin:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:$PATH
      '';
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      config.global = {
        warn_timeout = "10m";
      };
    };
  };
}
