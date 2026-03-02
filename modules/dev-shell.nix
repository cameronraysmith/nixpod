{
  perSystem =
    { pkgs, config, self', ... }:
    {
      apps.default.program = self'.packages.activate-home;

      devShells.default = pkgs.mkShell {
        name = "nixpod";
        inputsFrom = [
          config.pre-commit.devShell
        ];
        nativeBuildInputs = with pkgs; [
          act
          just
          ratchet
        ];
      };
    };
}
