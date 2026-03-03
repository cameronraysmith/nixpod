{ self, ... }:
{
  perSystem =
    {
      self',
      inputs',
      pkgs,
      lib,
      system,
      ...
    }:
    let
      buildNixImage = import ../containers/build-image.nix;
      nix2container = inputs'.nix2container.packages.nix2container;

      # Base packages for the default Nix profile, matching the legacy
      # defaultPkgs from nix-legacy.nix. These populate
      # /nix/var/nix/profiles/default/bin so commands are on PATH.
      defaultProfilePackages = with pkgs; [
        nix
        bashInteractive
        coreutils
        gnutar
        gzip
        gnugrep
        which
        curl
        less
        wget
        cacert
        findutils
        gitMinimal
      ];
    in
    {
      packages.nixpod =
        let
          nixpodNixConfig = import ../containers/nix-config.nix {
            inherit pkgs lib;
            profilePackages = defaultProfilePackages;
            nixConf = {
              allowed-users = [ "*" ];
              max-jobs = [ "auto" ];
              trusted-users = [
                "root"
                "jovyan"
                "runner"
              ];
            };
          };
        in
        buildNixImage {
          inherit nix2container pkgs lib;
          name = "nixpod";
          s6-overlay = self'.packages.s6-overlay-layer;
          userConfig = self'.packages.nixpod-users;
          nixConfig = nixpodNixConfig;
          storeOwner = {
            uid = 0;
            gid = 0;
            uname = "root";
            gname = "wheel";
          };
          extraPkgs = with pkgs; [
            ps
            su
            sudo
            tree
            vim
          ];
          extraContents = [ self'.legacyPackages.homeConfigurations.root.activationPackage ];
          cmd = [ "${pkgs.bashInteractive}/bin/bash" ];
        };

      # Enable 'nix run .#container to build an OCI tarball with the
      # home configuration activated.
      packages.container = self'.packages.nixpod;

      packages.ghanix =
        let
          atuinDaemonScript = pkgs.writeScript "atuin-daemon" ''
            #!/command/with-contenv ${pkgs.bashInteractive}/bin/bash
            printf "running atuin daemon\n\n"
            exec ${pkgs.atuin}/bin/atuin daemon
          '';
          atuinDaemonService = pkgs.runCommand "atuin-daemon" { } ''
            mkdir -p $out/etc/services.d/atuindaemon
            ln -s ${atuinDaemonScript} $out/etc/services.d/atuindaemon/run
          '';
          ghanixNixConfig = import ../containers/nix-config.nix {
            inherit pkgs lib;
            profilePackages = defaultProfilePackages;
            storeOwner = "runner";
            nixConf = {
              allowed-users = [ "*" ];
              max-jobs = [ "auto" ];
              trusted-users = [
                "root"
                "jovyan"
                "runner"
              ];
            };
          };
        in
        buildNixImage {
          inherit nix2container pkgs lib;
          name = "ghanix";
          s6-overlay = self'.packages.s6-overlay-layer;
          userConfig = self'.packages.nixpod-users;
          nixConfig = ghanixNixConfig;
          storeOwner = {
            uid = 1001;
            gid = 0;
            uname = "runner";
            gname = "wheel";
          };
          extraPkgs = with pkgs; [
            ps
            su
            sudo
            tree
            vim
          ];
          extraContents = [
            atuinDaemonService
            self'.legacyPackages.homeConfigurations.runner.activationPackage
          ];
          cmd = [ "${pkgs.bashInteractive}/bin/bash" ];
        };

      packages.codenix =
        let
          python = pkgs.python3.withPackages (
            ps: with ps; [
              pip
              ipykernel
            ]
          );
          username = "jovyan";
          storeOwner = {
            uid = 1000;
            gid = 0;
            uname = username;
            gname = "wheel";
          };
          activateUserHomeScript = pkgs.writeScript "activate-user-home-run" ''
            #!/command/with-contenv ${pkgs.runtimeShell}
            printf "activating home manager\n\n"
            /activate
            printf "home manager environment\n\n"
            printenv | sort
            printf "====================\n\n"
          '';
          activateUserHomeService = pkgs.runCommand "activate-user-home" { } ''
            mkdir -p $out/etc/cont-init.d
            ln -s ${activateUserHomeScript} $out/etc/cont-init.d/01-activate-user-home
          '';
          # https://gist.github.com/hyperupcall/99e355405611be6c4e0a38b6e3e8aad0#file-settings-jsonc
          installCodeServerExtensionsScript = pkgs.writeScript "install-code-extensions-run" ''
            #!/command/with-contenv ${pkgs.runtimeShell}
            # disable "donjayamanne.python-environment-manager"
            # from "donjayamanne.python-extension-pack"
            # due to https://github.com/microsoft/vscode/issues/210792#issuecomment-2186965405
            # also leaves out
            # "wholroyd.jinja"
            # "batisteo.vscode-django"
            VSCODE_EXTENSIONS=(
              "alefragnani.project-manager"
              "Catppuccin.catppuccin-vsc"
              "charliermarsh.ruff"
              "christian-kohler.path-intellisense"
              "cweijan.vscode-database-client2"
              "ms-python.python"
              "njpwerner.autodocstring"
              "KevinRose.vsc-python-indent"
              "eamodio.gitlens"
              "github.vscode-github-actions"
              "GitHub.vscode-pull-request-github"
              "ionutvmi.path-autocomplete"
              "jnoortheen.nix-ide"
              "ms-azuretools.vscode-docker"
              "ms-kubernetes-tools.vscode-kubernetes-tools"
              "ms-toolsai.jupyter"
              "njzy.stats-bar"
              "patbenatar.advanced-new-file"
              "rangav.vscode-thunder-client"
              "redhat.vscode-yaml"
              "sleistner.vscode-fileutils"
              "stkb.rewrap"
              "streetsidesoftware.code-spell-checker"
              "tamasfe.even-better-toml"
              "vscode-icons-team.vscode-icons"
              "vscodevim.vim"
              "richie5um2.vscode-sort-json"
            )

            printf "Listing currently installed extensions...\n\n"
            installed_extensions=$(code-server --list-extensions --show-versions)
            echo "$installed_extensions"
            echo ""

            install_command="code-server"
            for extension in "''${VSCODE_EXTENSIONS[@]}"; do
                install_command+=" --install-extension \"''${extension}\""
            done

            eval "''${install_command} --force"

            if echo "$installed_extensions" | ${pkgs.gnugrep}/bin/grep -q "nefrob.vscode-just-syntax"; then
                printf "vscode-just-syntax is already installed.\n"
            else
                printf "vscode-just-syntax is not installed. Proceeding with installation...\n"
                tmpdir=$(mktemp -d) && \
                curl --proto '=https' --tlsv1.2 -sSfL -o "$tmpdir/vscode-just-syntax-0.3.0.vsix" https://github.com/nefrob/vscode-just/releases/download/0.3.0/vscode-just-syntax-0.3.0.vsix && \
                code-server --install-extension "$tmpdir/vscode-just-syntax-0.3.0.vsix" && \
                rm -r "$tmpdir"
            fi

            printf "Listing extensions after installation...\n\n"
            code-server --list-extensions --show-versions

            settings_file="''${HOME}/.local/share/code-server/User/settings.json"
            mkdir -p "''${HOME}/.local/share/code-server/User"
            [ ! -s "''${settings_file}" ] && echo '{}' > "''${settings_file}"

            ${pkgs.jq}/bin/jq '{
              "gitlens.showWelcomeOnInstall": false,
              "gitlens.showWhatsNewAfterUpgrades": false,
              "python.terminal.activateEnvironment": false,
              "update.showReleaseNotes": false,
              "workbench.iconTheme": "vscode-icons",
              "workbench.colorTheme": "Catppuccin Macchiato",
            } + . ' "''${settings_file}" > "''${settings_file}.tmp" && mv "''${settings_file}.tmp" "''${settings_file}"

            printf "Updated settings in %s\n\n" "''${settings_file}"
          '';
          installCodeServerExtensionsService = pkgs.runCommand "install-code-extensions" { } ''
            mkdir -p $out/etc/cont-init.d
            ln -s ${installCodeServerExtensionsScript} $out/etc/cont-init.d/02-install-code-extensions
          '';
          codeServerScript = pkgs.writeScript "code-service-run" ''
            #!/command/with-contenv ${pkgs.bashInteractive}/bin/bash
            printf "code environment\n\n"
            export SHELL=${pkgs.zsh}/bin/zsh
            printenv | sort
            printf "====================\n\n"
            printf "Starting code-server with NB_PREFIX=''${NB_PREFIX}\n\n"
            cd "''${HOME}"
            exec code-server \
              --bind-addr 0.0.0.0:8888 \
              --disable-telemetry \
              --disable-update-check \
              --disable-workspace-trust \
              --disable-getting-started-override \
              --auth none \
              "''${HOME}"
          '';
          codeServerService = pkgs.runCommand "code-service" { } ''
            mkdir -p $out/etc/services.d/codeserver
            ln -s ${codeServerScript} $out/etc/services.d/codeserver/run
          '';
          atuinDaemonScript = pkgs.writeScript "atuin-daemon" ''
            #!/command/with-contenv ${pkgs.bashInteractive}/bin/bash
            printf "running atuin daemon\n\n"
            exec ${pkgs.atuin}/bin/atuin daemon
          '';
          atuinDaemonService = pkgs.runCommand "atuin-daemon" { } ''
            mkdir -p $out/etc/services.d/atuindaemon
            ln -s ${atuinDaemonScript} $out/etc/services.d/atuindaemon/run
          '';
          codenixNixConfig = import ../containers/nix-config.nix {
            inherit pkgs lib;
            profilePackages = defaultProfilePackages;
            storeOwner = username;
            nixConf = {
              allowed-users = [ "*" ];
              max-jobs = [ "auto" ];
              trusted-users = [
                "root"
                "jovyan"
                "runner"
              ];
            };
          };
        in
        buildNixImage {
          inherit
            nix2container
            pkgs
            lib
            storeOwner
            ;
          name = "codenix";
          s6-overlay = self'.packages.s6-overlay-layer;
          userConfig = self'.packages.nixpod-users;
          nixConfig = codenixNixConfig;
          extraPkgs =
            with pkgs;
            [
              code-server
              ps
              su
              sudo
              zsh
            ]
            ++ [ python ];
          extraContents = [
            activateUserHomeService
            installCodeServerExtensionsService
            atuinDaemonService
            codeServerService
            self'.legacyPackages.homeConfigurations.${username}.activationPackage
          ];
          extraEnv = [
            "NB_USER=${username}"
            "NB_UID=1000"
            "NB_PREFIX=/"
          ];
          extraConfig = {
            ExposedPorts = {
              "8888/tcp" = { };
            };
          };
          cmd = [ "${pkgs.bashInteractive}/bin/bash" ];
        };

      packages.jupnix =
        let
          python = pkgs.python3.withPackages (
            ps: with ps; [
              pip
              jupyterlab
            ]
          );
          username = "jovyan";
          storeOwner = {
            uid = 1000;
            gid = 0;
            uname = username;
            gname = "wheel";
          };
          activateUserHomeScript = pkgs.writeScript "activate-user-home-run" ''
            #!/command/with-contenv ${pkgs.runtimeShell}
            printf "activating home manager\n\n"
            /activate
            printf "home manager environment\n\n"
            printenv | sort
            printf "====================\n\n"
          '';
          activateUserHomeService = pkgs.runCommand "activate-user-home" { } ''
            mkdir -p $out/etc/cont-init.d
            ln -s ${activateUserHomeScript} $out/etc/cont-init.d/01-activate-user-home
          '';
          createJupyterLogScript = pkgs.writeScript "create-jupyter-log-run" ''
            #!/command/with-contenv ${pkgs.runtimeShell}
            /run/wrappers/bin/sudo mkdir -p /var/log/jupyterlab
            /run/wrappers/bin/sudo chown nobody:nobody /var/log/jupyterlab
            /run/wrappers/bin/sudo chmod 02777 /var/log/jupyterlab
          '';
          # createJupyterLogService will not be used if not added to extraContents
          # in buildNixImage below
          createJupyterLogService = pkgs.runCommand "create-jupyter-log" { } ''
            mkdir -p $out/etc/cont-init.d
            ln -s ${createJupyterLogScript} $out/etc/cont-init.d/02-create-jupyter-log
          '';
          jupyterServerScript = pkgs.writeScript "jupyter-service-run" ''
            #!/command/with-contenv ${pkgs.bashInteractive}/bin/bash
            printf "jupyter environment\n\n"
            export JUPYTER_RUNTIME_DIR="/tmp/jupyter_runtime"
            export SHELL=${pkgs.zsh}/bin/zsh
            printenv | sort
            printf "====================\n\n"
            printf "Starting jupyterlab with NB_PREFIX=''${NB_PREFIX}\n\n"
            cd "''${HOME}"
            exec jupyter lab \
              --notebook-dir="''${HOME}" \
              --ip=0.0.0.0 \
              --no-browser \
              --allow-root \
              --port=8888 \
              --ServerApp.token="" \
              --ServerApp.password="" \
              --ServerApp.allow_origin="*" \
              --ServerApp.allow_remote_access=True \
              --ServerApp.terminado_settings="shell_command=['${pkgs.zsh}/bin/zsh']" \
              --ServerApp.authenticate_prometheus=False \
              --ServerApp.base_url="''${NB_PREFIX}"
          '';
          jupyterLog = pkgs.writeScript "jupyter-log" ''
            #!/command/with-contenv ${pkgs.runtimeShell}
            exec logutil-service /var/log/jupyterlab
          '';
          # # Add the following to redirect stdout logging and manage rotation
          # mkdir -p $out/etc/services.d/jupyterlab/log
          # ln -s ${jupyterLog} $out/etc/services.d/jupyterlab/log/run
          jupyterServerService = pkgs.runCommand "jupyter-service" { } ''
            mkdir -p $out/tmp/jupyter_runtime
            mkdir -p $out/etc/services.d/jupyterlab
            ln -s ${jupyterServerScript} $out/etc/services.d/jupyterlab/run
          '';
          atuinDaemonScript = pkgs.writeScript "atuin-daemon" ''
            #!/command/with-contenv ${pkgs.bashInteractive}/bin/bash
            printf "running atuin daemon\n\n"
            exec ${pkgs.atuin}/bin/atuin daemon
          '';
          atuinDaemonService = pkgs.runCommand "atuin-daemon" { } ''
            mkdir -p $out/etc/services.d/atuindaemon
            ln -s ${atuinDaemonScript} $out/etc/services.d/atuindaemon/run
          '';
          jupnixNixConfig = import ../containers/nix-config.nix {
            inherit pkgs lib;
            profilePackages = defaultProfilePackages;
            storeOwner = username;
            nixConf = {
              allowed-users = [ "*" ];
              max-jobs = [ "auto" ];
              trusted-users = [
                "root"
                "jovyan"
                "runner"
              ];
            };
          };
        in
        buildNixImage {
          inherit
            nix2container
            pkgs
            lib
            storeOwner
            ;
          name = "jupnix";
          s6-overlay = self'.packages.s6-overlay-layer;
          userConfig = self'.packages.nixpod-users;
          nixConfig = jupnixNixConfig;
          extraPkgs =
            with pkgs;
            [
              musl
              ps
              su
              sudo
              zsh
            ]
            ++ [ python ];
          extraContents = [
            activateUserHomeService
            atuinDaemonService
            jupyterServerService
            self'.legacyPackages.homeConfigurations.${username}.activationPackage
          ];
          extraEnv = [
            "NB_USER=${username}"
            "NB_UID=1000"
            "NB_PREFIX=/"
          ];
          extraConfig = {
            ExposedPorts = {
              "8888/tcp" = { };
            };
          };
          cmd = [ "${pkgs.bashInteractive}/bin/bash" ];
        };

      legacyPackages.containerMatrix = {
        nixpod = {
          name = "nixpod";
          package = "container";
          inherit system;
        };
        ghanix = {
          name = "ghanix";
          package = "ghanix";
          inherit system;
        };
        codenix = {
          name = "codenix";
          package = "codenix";
          inherit system;
        };
        jupnix = {
          name = "jupnix";
          package = "jupnix";
          inherit system;
        };
      };
    };
}
