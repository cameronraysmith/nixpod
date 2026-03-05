# Nix daemon configuration derivation
#
# Produces a directory tree containing /etc/nix/nix.conf,
# /etc/profile.d/nix.sh, and profile directory structures
# for the specified store owner.
#
# Follows the patterns from upstream NixOS/nix docker.nix (2.33.3+):
# - lib.generators.toKeyValue for structured nix.conf generation
# - Correct profile symlinks using absolute /nix/var/nix/profiles/ paths
# - builtins.path for normalized nixpkgs store path names
{ ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    {
      _module.args.mkNixConfig =
        {
          nixConf ? { },
          profilePackages ? [ pkgs.nix ],
          storeOwner ? "root",
          storeOwnerUid ? 0,
          storeOwnerGid ? 0,
          channelName ? "nixpkgs",
          channelUrl ? "https://nixos.org/channels/nixpkgs-unstable",
          bundleNixpkgs ? true,
        }:
        let
          userHome = if storeOwner == "root" then "/root" else "/home/${storeOwner}";

          # Structured nix.conf generation using lib.generators.toKeyValue
          # following the upstream NixOS/nix docker.nix pattern.
          toConf = lib.generators.toKeyValue {
            mkKeyValue = lib.generators.mkKeyValueDefault {
              mkValueString =
                v:
                if lib.isList v then
                  lib.concatStringsSep " " (map (lib.generators.mkValueStringDefault { }) v)
                else
                  lib.generators.mkValueStringDefault { } v;
            } " = ";
          };

          defaultNixConf = {
            sandbox = false;
            build-users-group = "nixbld";
            experimental-features = [
              "nix-command"
              "flakes"
            ];
            trusted-users = [ "root" ] ++ lib.optional (storeOwner != "root") storeOwner;
            trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
          };

          nixConfContents = toConf (defaultNixConf // nixConf);

          # Profile script that sources nix-daemon.sh for login shells
          nixProfileScript = pkgs.writeTextDir "etc/profile.d/nix.sh" ''
            # Nix
            if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
                . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
            fi
            # End Nix
          '';

          # nix.conf file
          nixConfDir = pkgs.writeTextDir "etc/nix/nix.conf" nixConfContents;

          # Channel setup using builtins.path to normalize nixpkgs store path names
          nixpkgs = pkgs.path;
          channel = pkgs.runCommand "channel-nixos" { inherit bundleNixpkgs; } ''
            mkdir $out
            if [ "$bundleNixpkgs" ]; then
              ln -s ${
                builtins.path {
                  path = nixpkgs;
                  name = "source";
                }
              } $out/nixpkgs
              echo "[]" > $out/manifest.nix
            fi
          '';

          # Profile environment containing packages reachable via the default
          # profile's bin directory (/nix/var/nix/profiles/default/bin).
          rootEnv = pkgs.buildPackages.buildEnv {
            name = "root-profile-env";
            paths = profilePackages;
          };

          manifest = pkgs.buildPackages.runCommand "manifest.nix" { } ''
            cat > $out <<EOF
            [
            ${lib.concatStringsSep "\n" (
              builtins.map (
                drv:
                let
                  outputs = drv.outputsToInstall or [ "out" ];
                in
                ''
                  {
                    ${lib.concatStringsSep "\n" (
                      builtins.map (output: ''
                        ${output} = { outPath = "${lib.getOutput output drv}"; };
                      '') outputs
                    )}
                    outputs = [ ${lib.concatStringsSep " " (builtins.map (x: "\"${x}\"") outputs)} ];
                    name = "${drv.name}";
                    outPath = "${drv}";
                    system = "${drv.system}";
                    type = "derivation";
                    meta = { };
                  }
                ''
              ) profilePackages
            )}
            ]
            EOF
          '';

          profile = pkgs.buildPackages.runCommand "user-environment" { } ''
            mkdir $out
            cp -a ${rootEnv}/* $out/
            ln -s ${manifest} $out/manifest.nix
          '';

          # Profile directory structure with correct symlinks.
          #
          # The 2.18.3 version of docker.nix had a bug where profile symlinks
          # pointed to $out/nix/var/nix/profiles/... (the build-time store path)
          # instead of /nix/var/nix/profiles/... (the runtime absolute path).
          # This was fixed in the upstream 2.33.3 docker.nix.
          #
          # We follow the fixed pattern: all symlinks use absolute /nix/... paths
          # so they resolve correctly at container runtime regardless of the store
          # path that contained them during build.
          profileDirs =
            pkgs.runCommand "nix-profile-dirs"
              {
                allowSubstitutes = false;
                preferLocalBuild = true;
              }
              ''
                mkdir -p $out/nix/var/nix/profiles/per-user/${storeOwner}
                mkdir -p $out/nix/var/nix/gcroots

                # Default profile: link the built environment and create the
                # generation chain using absolute paths (the 2.33.3 fix).
                ln -s ${profile} $out/nix/var/nix/profiles/default-1-link
                ln -s /nix/var/nix/profiles/default-1-link $out/nix/var/nix/profiles/default

                # User .nix-profile symlink using absolute path
                mkdir -p $out${userHome}
                ln -s /nix/var/nix/profiles/default $out${userHome}/.nix-profile

                # Channel setup using absolute paths (the 2.33.3 fix)
                ln -s ${channel} $out/nix/var/nix/profiles/per-user/${storeOwner}/channels-1-link
                ln -s /nix/var/nix/profiles/per-user/${storeOwner}/channels-1-link $out/nix/var/nix/profiles/per-user/${storeOwner}/channels

                # .nix-defexpr with channel link using absolute path
                mkdir -p $out${userHome}/.nix-defexpr
                ln -s /nix/var/nix/profiles/per-user/${storeOwner}/channels $out${userHome}/.nix-defexpr/channels

                # .nix-channels file
                echo "${channelUrl} ${channelName}" > $out${userHome}/.nix-channels
              '';

        in
        pkgs.symlinkJoin {
          name = "nixpod-nix-config";
          paths = [
            nixConfDir
            nixProfileScript
            profileDirs
          ];
        };
    };
}
