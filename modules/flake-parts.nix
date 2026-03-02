{ inputs, ... }:
{
  imports = [
    inputs.nixos-flake.flakeModule
  ];

  perSystem = {
    nixos-flake = {
      primary-inputs = [
        "nixpkgs"
        "home-manager"
        "nixos-flake"
      ];
    };
  };
}
