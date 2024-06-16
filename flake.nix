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

            # Enable 'nix run .#nixImage' to build an OCI tarball containing 
            # a nix store.
            nixImage = pkgs.dockerTools.buildImageWithNixDb {
              name = "niximage";
              tag = "latest";
              copyToRoot = pkgs.buildEnv {
                name = "niximage-root";
                pathsToLink = [ "/bin" ];
                paths = with pkgs; [
                  bashInteractive
                  coreutils
                  nix
                  dockerTools.caCertificates
                  su
                  sudo
                ];
              };
              runAsRoot = ''
                ${pkgs.dockerTools.shadowSetup}

                # normally 
                # groupadd -g 0 wheel
                # usermod -aG wheel root
                # but dockerTools.shadowSetup
                # sets the root group to 0

                groupadd -g 30000 nixbld

                groupadd -g 65534 nobody
                useradd -u 65534 -g 65534 -d /var/empty nobody
                usermod -aG nixbld nobody

                mkdir -p /tmp
                mkdir -p /root

                mkdir -p /etc/nix
                cat > /etc/nix/nix.conf <<EOF
                build-users-group = nixbld
                experimental-features = nix-command flakes
                max-jobs = auto
                extra-nix-path = nixpkgs=flake:nixpkgs
                trusted-users = root
                EOF

                echo "hosts: files dns" > /etc/nsswitch.conf

                mkdir -p ${homeDir}
                groupadd -g ${myUserGid} ${myUserName}
                useradd -u ${myUserUid} -g ${myUserGid} -d ${homeDir} ${myUserName}
                usermod -aG root ${myUserName}
                chown -R ${myUserUid}:${myUserGid} ${homeDir}
              '';
              config = {
                Env = [
                  "NIX_PAGER=cat"
                  "USER=root"
                ];
              };
            };

            # Enable 'nix run .#container to build an OCI tarball with the 
            # home configuration activated.
            container = pkgs.dockerTools.buildLayeredImage {
              name = "nixpod";
              tag = "latest";
              fromImage = nixImage;
              maxLayers = 100;
              contents = with pkgs; [
                default
                # homeConfig.activationPackage
              ];
              fakeRootCommands = ''
                cd ${homeDir} && \
                sudo -u ${myUserName} ${self'.packages.activate-home}/bin/activate-home
              '';
              enableFakechroot = true;
              config = {
                Cmd = [
                  "${pkgs.bashInteractive}/bin/bash"
                  "-c"
                  "exec ${pkgs.zsh}/bin/zsh"
                ];
                Env = [
                  "USER=${myUserName}"
                  "HOME=${homeDir}"
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
