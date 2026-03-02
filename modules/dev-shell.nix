{
  perSystem =
    { pkgs, self', ... }:
    {
      apps.default.program = self'.packages.activate-home;

      devShells.default = pkgs.mkShell {
        name = "nixpod";
        nativeBuildInputs = with pkgs; [
          act
          just
          ratchet
        ];
      };
    };
}
