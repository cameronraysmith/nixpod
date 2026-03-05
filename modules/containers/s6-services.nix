# Shared s6 service definitions for container variants.
#
# Services that appear identically across multiple container variants
# are extracted here to avoid duplication.
{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      _module.args.containerS6Services = {
        atuinDaemon =
          let
            script = pkgs.writeScript "atuin-daemon" ''
              #!/command/with-contenv ${pkgs.bashInteractive}/bin/bash
              printf "running atuin daemon\n\n"
              exec ${pkgs.atuin}/bin/atuin daemon
            '';
          in
          pkgs.runCommand "atuin-daemon" { } ''
            mkdir -p $out/etc/services.d/atuindaemon
            ln -s ${script} $out/etc/services.d/atuindaemon/run
          '';

        activateUserHome =
          let
            script = pkgs.writeScript "activate-user-home-run" ''
              #!/command/with-contenv ${pkgs.runtimeShell}
              printf "activating home manager\n\n"
              /activate
              printf "home manager environment\n\n"
              printenv | sort
              printf "====================\n\n"
            '';
          in
          pkgs.runCommand "activate-user-home" { } ''
            mkdir -p $out/etc/cont-init.d
            ln -s ${script} $out/etc/cont-init.d/01-activate-user-home
          '';
      };
    };
}
