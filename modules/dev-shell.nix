{
  perSystem =
    {
      pkgs,
      config,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        name = "nixpod";
        inputsFrom = [
          config.pre-commit.devShell
        ];
        nativeBuildInputs = with pkgs; [
          act
          age
          bun
          gitleaks
          just
          nix-output-monitor
          nodejs_24 # semantic-release >= 24.10.0 requires node ^22.14.0 || >= 24.10.0
          ratchet
          sops
          ssh-to-age
        ];
        shellHook = ''
          export GIT_REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "unknown")
          export GIT_REF=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null || echo "detached")
          export GIT_SHA=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
          export GIT_SHA_SHORT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
        '';
      };
    };
}
