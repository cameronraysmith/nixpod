{ self, inputs, ... }:
{
  perSystem =
    {
      pkgs,
      lib,
      self',
      system,
      ...
    }:
    let
      users = [
        "root"
        "jovyan"
        "runner"
      ];
      myUserName = "runner";
      githubOrg = "cameronraysmith";
      buildS6OverlayLayer = import ../containers/s6-overlay.nix;
    in
    {
      legacyPackages.homeConfigurations = builtins.listToAttrs (
        map (user: {
          name = user;
          value = inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              (
                { pkgs, ... }:
                {
                  imports = [ self.homeModules.default ];
                  home.username = user;
                  home.homeDirectory =
                    if user == "root" then "/root" else "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${user}";
                }
              )
            ];
          };
        }) users
      );

      packages = {
        # Enable 'nix build' to build the home configuration, without
        # activating it.
        default = self'.legacyPackages.homeConfigurations.${myUserName}.activationPackage;

        s6-overlay-layer = buildS6OverlayLayer { inherit pkgs system; };

        nixpod-users = import ../containers/users.nix {
          inherit pkgs lib;
        };

        nixpod-nix-config = import ../containers/nix-config.nix {
          inherit pkgs lib;
        };
      };
    };
}
