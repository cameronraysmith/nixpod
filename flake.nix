{
  description = "A portable flake for Nix-based development when you cannot necessarily use NixOS";

  inputs = {
    # Principle inputs (updated by `nix run .#update`)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    catppuccin.url = "github:catppuccin/nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-flake.url = "github:srid/nixos-flake";
    flocken = {
      url = "github:mirkolenz/flocken/v2";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.systems.follows = "systems";
    };

    # see https://github.com/nix-systems/default/blob/main/default.nix
    systems.url = "github:nix-systems/default";
  };

  outputs =
    inputs @ { self
    , flake-parts
    , ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [
        inputs.nixos-flake.flakeModule
        ./home
      ];

      perSystem = { self', inputs', pkgs, system, ... }:
        let
          # users = {
          #   root = {
          #     name = "root";
          #     uid = "0";
          #     gid = "0";
          #   };
          #   runner = {
          #     name = "runner";
          #     uid = "1001";
          #     gid = "121";
          #   };
          #   jovyan = {
          #     name = "jovyan";
          #     uid = "1000";
          #     gid = "100";
          #   };
          # };
          users = [ "root" "jovyan" "runner" ];
          myUserName = "runner";
          myUserUid = "1001";
          myUserGid = "121";
          homeDir =
            if myUserName == "root"
            then "/root"
            else "/${
            if pkgs.stdenv.isDarwin
            then "Users"
            else "home"
          }/${myUserName}";
          homeConfig = inputs.self.nixos-flake.lib.mkHomeConfiguration
            pkgs
            ({ pkgs, ... }: {
              imports = [
                inputs.self.homeModules.default
                inputs.catppuccin.homeManagerModules.catppuccin
              ];
              home.username = myUserName;
              home.homeDirectory = homeDir;
              home.stateVersion = "23.11";
            });
          includedSystems =
            let
              envVar = builtins.getEnv "NIX_IMAGE_SYSTEMS";
            in
            if envVar == ""
            then [ "x86_64-linux" "aarch64-linux" ]
            else builtins.filter (sys: sys != "") (builtins.split " " envVar);
        in
        {
          # Enable 'nix fmt' to lint with nixpkgs-fmt
          formatter = pkgs.nixpkgs-fmt;

          # Enable 'nix run' to activate home-manager.
          apps.default.program = self'.packages.activate-home;

          # Enable 'nix develop' to activate the development shell.
          devShells.default = pkgs.mkShell {
            name = "nixpod-home";
            nativeBuildInputs = with pkgs; [
              act
              just
              ratchet
            ];
          };

          packages = rec {
            # Enable 'nix build' to build the home configuration, without
            # activating it.
            default = self'.legacyPackages.homeConfigurations.${myUserName}.activationPackage;

            pamImage = pkgs.dockerTools.buildImage {
              name = "pamimage";
              tag = "latest";

              copyToRoot = pkgs.pam;

              runAsRoot = ''
                #!${pkgs.runtimeShell}

                mkdir -p /etc/pam.d
              '';
            };

            suImage = pkgs.dockerTools.buildImage {
              name = "suimage";
              tag = "latest";
              fromImage = pamImage;

              copyToRoot = pkgs.su;
            };

            sudoImage = pkgs.dockerTools.buildImage {
              name = "sudoimage";
              tag = "latest";
              fromImage = suImage;

              copyToRoot = pkgs.sudo;

              runAsRoot = ''
                #!${pkgs.runtimeShell}

                mkdir -p /etc/pam.d/backup
                ${pkgs.findutils}/bin/find /etc/pam.d -type f -exec mv {} /etc/pam.d/backup/ \; 2>/dev/null || true

                cat > /etc/pam.d/sudo <<EOF
                #%PAM-1.0
                auth        sufficient  pam_rootok.so
                auth        sufficient  pam_permit.so
                account     sufficient  pam_permit.so
                account     required    pam_warn.so
                session     required    pam_permit.so
                password    sufficient  pam_permit.so
                EOF

                cat > /etc/pam.d/su <<EOF
                #%PAM-1.0
                auth        sufficient  pam_rootok.so
                auth        sufficient  pam_permit.so
                account     sufficient  pam_permit.so
                account     required    pam_warn.so
                session     required    pam_permit.so
                password    sufficient  pam_permit.so
                EOF

                cat > /etc/pam.d/system-auth <<EOF
                #%PAM-1.0
                auth        required      pam_env.so
                auth        sufficient    pam_rootok.so
                auth        sufficient    pam_permit.so
                auth        sufficient    pam_unix.so try_first_pass nullok
                auth        required      pam_deny.so
                account     sufficient    pam_permit.so
                account     required      pam_unix.so
                password    sufficient    pam_permit.so
                password    required      pam_unix.so
                session     required      pam_unix.so
                session     optional      pam_permit.so
                EOF

                cat > /etc/pam.d/login <<EOF
                #%PAM-1.0
                auth        required      pam_env.so
                auth        sufficient    pam_rootok.so
                auth        sufficient    pam_permit.so
                auth        sufficient    pam_unix.so try_first_pass nullok
                auth        required      pam_deny.so
                account     sufficient    pam_permit.so
                account     required      pam_unix.so
                password    sufficient    pam_permit.so
                password    required      pam_unix.so
                session     required      pam_unix.so
                session     optional      pam_permit.so
                EOF

                chmod +s /sbin/sudo

                cat >> /etc/sudoers <<EOF
                root     ALL=(ALL:ALL)    NOPASSWD:SETENV: ALL
                %wheel  ALL=(ALL:ALL)    NOPASSWD:SETENV: ALL
                EOF
              '';
            };

            nixImage = (import ./containers/multiuser-container.nix) {
              inherit pkgs;
              name = "multiusernix";
              tag = "latest";
              maxLayers = 70;
              fromImage = sudoImage;
              extraPkgs = with pkgs; [
                ps
                s6
                su
                sudo
                tree
                vim
              ];
              nixConf = {
                allowed-users = [ "*" ];
                experimental-features = [ "nix-command" "flakes" ];
                max-jobs = [ "auto" ];
                sandbox = "false";
                trusted-users = [ "root" "jovyan" "runner" ];
              };
            };

            # Enable 'nix run .#container to build an OCI tarball with the 
            # home configuration activated.
            container = pkgs.dockerTools.buildLayeredImage {
              name = "nixpod";
              tag = "latest";
              created = "now";
              fromImage = nixImage;
              maxLayers = 111;
              contents = with pkgs; [
                default
              ];
              config = {
                Entrypoint = [ "/opt/scripts/entrypoint.sh" ];
                Cmd = [ "/root/.nix-profile/bin/bash" ];
                Env = [
                  #   "NIX_REMOTE=daemon"
                ];
              };
            };
          };

          legacyPackages = {
            # Make home-manager configuration
            homeConfigurations.${myUserName} = homeConfig;

            # Combine OCI json for includedSystems and push to registries
            containerManifest = inputs'.flocken.legacyPackages.mkDockerManifest {
              github = {
                enable = true;
                enableRegistry = false;
                token = "$GH_TOKEN";
              };
              autoTags = {
                branch = false;
              };
              registries = {
                "ghcr.io" = {
                  enable = true;
                  repo = "cameronraysmith/nixpod";
                  username = builtins.getEnv "GITHUB_ACTOR";
                  password = "$GH_TOKEN";
                };
              };
              version = builtins.getEnv "VERSION";
              images = builtins.map (sys: self.packages.${sys}.container) includedSystems;
              tags = [
                (builtins.getEnv "GIT_SHA_SHORT")
                (builtins.getEnv "GIT_SHA")
                (builtins.getEnv "GIT_REF")
              ];
            };
          };
        };
    };
}
