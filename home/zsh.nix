{ lib, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;

    envExtra = ''
      # Ensure all nix and home-manager installed files are available in PATH.
      export PATH=/run/wrappers/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/opt/homebrew/bin:$PATH
    '';

    initExtraBeforeCompInit = ''
      ZSH_DISABLE_COMPFIX=true
    '';

    initExtra = ''
      # Shell function to compute the sha256 nix hash of a file from a url.
      get_nix_hash() {
        url="$1";
        nix_hash=$(nix-prefetch-url "$url");
        nix hash to-sri --type sha256 "$nix_hash";
      }

      # Shell function to check differences between the current branch and the
      # upstream branch prior to merge.
      pmc() {
        export PAGER=cat
        branch=''${1:-upstream/main}
        echo 'Commit Summary:'
        git log HEAD..$branch --oneline
        echo
        echo 'Detailed Commit Logs:'
        git log HEAD..$branch
        echo
        echo 'Files Changed (Name Status):'
        git diff --name-status HEAD...$branch
        unset PAGER
      }

      # List the active scopes of a GitHub legacy PAT provided as argument.
      check_github_token_scopes() {
        if [ -z "$1" ]; then
          echo "Usage: check_github_token_scopes <your_github_token>"
          return 1
        fi

        token=$1
        curl -sS -f -I -H "Authorization: token $token" https://api.github.com | grep -i x-oauth-scopes
      }

    '';

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "rust"
        "vi-mode"
        "zoxide"
      ];
      theme = "robbyrussell";
    };

    syntaxHighlighting = {
      enable = true;
    };
  };
}
