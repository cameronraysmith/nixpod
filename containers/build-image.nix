# nix2container-based multi-user Nix container image builder.
#
# Replaces the dockerTools-based buildMultiUserNixImage with
# nix2container.buildImage for deferred tar creation and
# efficient layer management.
#
# Composes three foundation derivations:
# - s6-overlay (process supervision)
# - userConfig (system identity: passwd/group/shadow/PAM/sudoers)
# - nixConfig (nix.conf, profile dirs, nix.sh)
#
# Layer architecture:
# - Layer 1 (base): shell utilities rarely changing across variants
# - Layer 2 (nix): Nix package closure for daemon operation
# - Layer 3 (s6): s6-overlay filesystem layout
# - Layer 4 (nix-config): Nix daemon config rewritten to root
#   (isolated from customization layer to avoid /nix path conflicts
#   with initializeNixDatabase)
# - Customization layer (copyToRoot): userConfig, runtime dirs,
#   extra contents varying per variant
{
  nix2container,
  pkgs,
  lib ? pkgs.lib,
  name,
  tag ? "latest",
  s6-overlay,
  userConfig,
  nixConfig,
  storeOwner ? {
    uid = 0;
    gid = 0;
    uname = "root";
    gname = "root";
  },
  extraPkgs ? [ ],
  extraContents ? [ ],
  entrypoint ? [ "/init" ],
  cmd ? [ ],
  extraEnv ? [ ],
  extraConfig ? { },
}:
let
  # Layer 1: base shell utilities. These change infrequently and
  # are shared across all container variants.
  baseLayer = nix2container.buildLayer {
    deps = with pkgs; [
      bashInteractive
      coreutils
      gnugrep
      gnutar
      gzip
      less
      which
      curl
      wget
      findutils
      cacert
      gitMinimal
    ];
  };

  # Layer 2: Nix package and its closure for daemon operation.
  nixLayer = nix2container.buildLayer {
    deps = [ pkgs.nix ];
    layers = [ baseLayer ];
  };

  # Layer 3: s6-overlay filesystem layout (/init, /command/, etc).
  s6Layer = nix2container.buildLayer {
    deps = [ s6-overlay ];
    layers = [
      baseLayer
      nixLayer
    ];
  };

  # Layer 4: Nix daemon configuration rewritten to image root.
  # This layer is isolated from the customization layer because
  # nixConfig produces /nix/var/nix/profiles/ paths that would
  # conflict with the /nix/ paths created by initializeNixDatabase
  # in the customization layer. Placing nixConfig in its own layer
  # ensures its store path is excluded from the customization layer
  # by nix2container's layer deduplication.
  nixConfigLayer = nix2container.buildLayer {
    copyToRoot = [ nixConfig ];
    layers = [
      baseLayer
      nixLayer
      s6Layer
    ];
  };

  # Filesystem directories that must exist at runtime but are not
  # produced by any of the foundation derivations.
  #
  # Paths under /nix/ are excluded: initializeNixDatabase creates
  # /nix/var/nix/db, /nix/var/nix/gcroots/docker, and /nix/store/.links;
  # nixConfig creates /nix/var/nix/profiles and gcroots directories.
  # Mixing /nix/ paths here with the nix database would cause tar
  # entry conflicts in the customization layer.
  runtimeDirs =
    pkgs.runCommand "runtime-dirs"
      {
        allowSubstitutes = false;
        preferLocalBuild = true;
      }
      ''
        mkdir -p $out/tmp
        mkdir -p $out/var/tmp
        mkdir -p $out/var/log
        mkdir -p $out/run/wrappers/bin
        ln -s /run $out/var/run

        mkdir -p $out/etc/ssl/certs
        ln -s /nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt $out/etc/ssl/certs

        mkdir -p $out/usr
        ln -s /nix/var/nix/profiles/share $out/usr/

        mkdir -p $out/bin $out/usr/bin
        ln -s ${pkgs.coreutils}/bin/env $out/usr/bin/env
        ln -s ${pkgs.bashInteractive}/bin/bash $out/bin/sh
      '';

  # The sudo wrapper is a copy with setuid-like permissions.
  # In nix2container we set perms instead of fakeroot chown/chmod.
  sudoWrapper =
    pkgs.runCommand "sudo-wrapper"
      {
        allowSubstitutes = false;
        preferLocalBuild = true;
      }
      ''
        mkdir -p $out/run/wrappers/bin
        cp ${pkgs.sudo}/bin/sudo $out/run/wrappers/bin/sudo
      '';

  # Assemble copyToRoot content via buildEnv to merge all trees.
  # nixConfig is excluded: it goes into nixConfigLayer to avoid
  # /nix path conflicts with initializeNixDatabase.
  rootEnv = pkgs.buildEnv {
    name = "root";
    paths = [
      userConfig
      runtimeDirs
      sudoWrapper
    ]
    ++ extraContents
    ++ (map (pkg: pkg) extraPkgs);
    pathsToLink = [
      "/"
    ];
  };

  userHome = if storeOwner.uname == "root" then "/root" else "/home/${storeOwner.uname}";

in
nix2container.buildImage {
  inherit name tag;

  initializeNixDatabase = true;
  nixUid = 0;
  nixGid = 0;

  layers = [
    baseLayer
    nixLayer
    s6Layer
    nixConfigLayer
  ];

  copyToRoot = [ rootEnv ];

  perms = [
    # Home directories owned by storeOwner
    {
      path = userConfig;
      regex = "/home/.*";
      mode = "0750";
      uid = storeOwner.uid;
      gid = storeOwner.gid;
    }
    # Root home owned by root
    {
      path = userConfig;
      regex = "/root";
      mode = "0750";
      uid = 0;
      gid = 0;
    }
    # Shadow file restricted
    {
      path = userConfig;
      regex = "/etc/shadow";
      mode = "0640";
      uid = 0;
      gid = 0;
    }
    # Sticky bit directories
    {
      path = runtimeDirs;
      regex = "/tmp";
      mode = "1777";
    }
    {
      path = runtimeDirs;
      regex = "/var/tmp";
      mode = "1777";
    }
    {
      path = runtimeDirs;
      regex = "/var/log";
      mode = "1777";
    }
    # Sudo wrapper with setuid
    {
      path = sudoWrapper;
      regex = "/run/wrappers/bin/sudo";
      mode = "4755";
      uid = 0;
      gid = 0;
    }
  ];

  config = {
    Entrypoint = entrypoint;
    Cmd = cmd;
    User = "${toString storeOwner.uid}:${toString storeOwner.gid}";
    Env = [
      "USER=${storeOwner.uname}"
      "HOME=${userHome}"
      "PATH=${
        lib.concatStringsSep ":" [
          "/run/wrappers/bin"
          "${userHome}/.nix-profile/bin"
          "/nix/profile/bin"
          "${userHome}/.local/state/nix/profile/bin"
          "/etc/profiles/per-user/${storeOwner.uname}/bin"
          "/nix/var/nix/profiles/default/bin"
          "/nix/var/nix/profiles/default/sbin"
          "/run/current-system/sw/bin"
        ]
      }"
      "MANPATH=${
        lib.concatStringsSep ":" [
          "${userHome}/.nix-profile/share/man"
          "/nix/var/nix/profiles/default/share/man"
        ]
      }"
      "SSL_CERT_FILE=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
      "CURL_CA_BUNDLE=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
      "GIT_SSL_CAINFO=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
      "NIX_SSL_CERT_FILE=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
      "NIX_PATH=/nix/var/nix/profiles/per-user/${storeOwner.uname}/channels:${userHome}/.nix-defexpr/channels"
      "S6_CMD_WAIT_FOR_SERVICES_MAXTIME=300000"
    ]
    ++ extraEnv;
  }
  // extraConfig;
}
