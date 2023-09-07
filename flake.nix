{
  inputs = {
    # Principle inputs (updated by `nix run .#update`)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-flake.url = "github:srid/nixos-flake";
    systems.url = "github:nix-systems/default";
  };

  outputs = inputs @ { 
    self,
    nixpkgs,
    home-manager,
    flake-parts,
    nixos-flake,
    systems,
    ...
  }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      # systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      systems = import systems;
      imports = [
        inputs.nixos-flake.flakeModule
      ];

      flake.homeModules.default = ./home.nix;

      flake.templates.default = {
        description = "A `home-manager` template providing useful tools & settings for Nix-based development";
        path = builtins.path {
          path = ./.;
          filter = path: _:
            !(inputs.nixpkgs.lib.hasSuffix "LICENSE" path ||
              inputs.nixpkgs.lib.hasSuffix "README.md" path);
        };
      };

      perSystem = { self', pkgs, ... }:
        let
          myUserName = "runner";
        in
        {
          legacyPackages.homeConfigurations.${myUserName} =
            self.nixos-flake.lib.mkHomeConfiguration
              pkgs
              ({ pkgs, ... }: {
                imports = [ self.homeModules.default ];
                home.username = myUserName;
                home.homeDirectory = "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${myUserName}";
                home.stateVersion = "22.11";
              });

          # Enables 'nix run' to activate.
          apps.default.program = self'.packages.activate-home;

          # Enable 'nix build' to build the home configuration, but without
          # activating.
          packages.default = self'.legacyPackages.homeConfigurations.${myUserName}.activationPackage;
        };
    };
}
