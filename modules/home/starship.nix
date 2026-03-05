{ ... }:
{
  flake.modules.homeManager.starship =
    { ... }:
    {
      programs.starship = {
        enable = true;
        settings = {
          command_timeout = 2000;
        };
      };
    };
}
