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
      };
    };
}
