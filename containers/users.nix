# Multi-user system configuration derivation for nix2container images.
#
# Produces a single store path containing /etc/ tree with:
# - passwd, group, shadow (user accounts)
# - pam.d/ (PAM configuration for sudo, su, system-auth, login)
# - sudoers.d/ (NOPASSWD wheel group)
#
# User/group definitions and PAM/sudoers configs are decoupled from the
# container build backend for reuse across image variants.
{
  pkgs,
  lib ? pkgs.lib,
  storeOwner ? {
    uid = 0;
    gid = 0;
    uname = "root";
    gname = "wheel";
  },
  extraUsers ? { },
  extraGroups ? { },
}:
let
  # Non-root user accounts with explicit uid/gid/shell/home.
  nonRootUsers = {
    jovyan = {
      uid = 1000;
      shell = "${pkgs.bashInteractive}/bin/bash";
      home = "/home/jovyan";
      gid = 100;
      groups = [
        "jovyan"
        "users"
        "wheel"
      ];
      description = "Privileged Jupyter user";
    };

    runner = {
      uid = 1001;
      shell = "${pkgs.bashInteractive}/bin/bash";
      home = "/home/runner";
      gid = 121;
      groups = [
        "runner"
        "docker"
        "users"
        "wheel"
      ];
      description = "Privileged GitHub Actions user";
    };
  };

  users = {
    root = {
      uid = 0;
      shell = "${pkgs.bashInteractive}/bin/bash";
      home = "/root";
      gid = 0;
      groups = [ "wheel" ];
      description = "System administrator";
    };

    nobody = {
      uid = 65534;
      shell = "${pkgs.shadow}/bin/nologin";
      home = "/var/empty";
      gid = 65534;
      groups = [ "nobody" ];
      description = "Unprivileged account (don't use!)";
    };
  }
  // nonRootUsers
  // lib.listToAttrs (
    map (n: {
      name = "nixbld${toString n}";
      value = {
        uid = 30000 + n;
        gid = 30000;
        groups = [ "nixbld" ];
        description = "Nix build user ${toString n}";
      };
    }) (lib.lists.range 1 32)
  )
  // extraUsers;

  groups = {
    wheel.gid = 0;
    users.gid = 100;
    docker.gid = 121;
    jovyan.gid = 1000;
    runner.gid = 1001;
    nixbld.gid = 30000;
    nobody.gid = 65534;
  }
  // extraGroups;

  # passwd generation: user:x:uid:gid:description:home:shell
  userToPasswd =
    k:
    {
      uid,
      gid ? 65534,
      home ? "/var/empty",
      description ? "",
      shell ? "/bin/false",
      groups ? [ ],
    }:
    "${k}:x:${toString uid}:${toString gid}:${description}:${home}:${shell}";

  passwdContents = lib.concatStringsSep "\n" (lib.attrValues (lib.mapAttrs userToPasswd users));

  # shadow generation: user:!:1::::::
  userToShadow = k: { ... }: "${k}:!:1::::::";
  shadowContents = lib.concatStringsSep "\n" (lib.attrValues (lib.mapAttrs userToShadow users));

  # group membership mapping: { group = [ "user1" "user2" ]; }
  groupMemberMap =
    let
      mappings = builtins.foldl' (
        acc: user:
        let
          memberGroups = users.${user}.groups or [ ];
        in
        acc
        ++ map (group: {
          inherit user group;
        }) memberGroups
      ) [ ] (lib.attrNames users);
    in
    builtins.foldl' (
      acc: v:
      acc
      // {
        ${v.group} = acc.${v.group} or [ ] ++ [ v.user ];
      }
    ) { } mappings;

  # group generation: group:x:gid:member1,member2
  groupToGroup =
    k:
    { gid }:
    let
      members = groupMemberMap.${k} or [ ];
    in
    "${k}:x:${toString gid}:${lib.concatStringsSep "," members}";

  groupContents = lib.concatStringsSep "\n" (lib.attrValues (lib.mapAttrs groupToGroup groups));

  # PAM configuration for container authentication services.
  # Each file under /etc/pam.d/ configures authentication for a service.
  pamSudo = ''
    #%PAM-1.0
    auth        sufficient  pam_rootok.so
    auth        sufficient  pam_permit.so
    account     sufficient  pam_permit.so
    account     required    pam_warn.so
    session     required    pam_permit.so
    password    sufficient  pam_permit.so
  '';

  pamSu = ''
    #%PAM-1.0
    auth        sufficient  pam_rootok.so
    auth        sufficient  pam_permit.so
    account     sufficient  pam_permit.so
    account     required    pam_warn.so
    session     required    pam_permit.so
    password    sufficient  pam_permit.so
  '';

  pamSystemAuth = ''
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
  '';

  pamLogin = ''
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
  '';

  # Sudoers configuration granting passwordless sudo to root and wheel group.
  sudoersWheel = ''
    root     ALL=(ALL:ALL)    NOPASSWD:SETENV: ALL
    %wheel  ALL=(ALL:ALL)    NOPASSWD:SETENV: ALL
  '';

in
pkgs.runCommand "nixpod-users"
  {
    inherit
      passwdContents
      groupContents
      shadowContents
      ;
    passAsFile = [
      "passwdContents"
      "groupContents"
      "shadowContents"
    ];
    allowSubstitutes = false;
    preferLocalBuild = true;
  }
  ''
    set -euo pipefail

    mkdir -p $out/etc

    # User accounts
    cat $passwdContentsPath > $out/etc/passwd
    echo "" >> $out/etc/passwd

    cat $groupContentsPath > $out/etc/group
    echo "" >> $out/etc/group

    cat $shadowContentsPath > $out/etc/shadow
    echo "" >> $out/etc/shadow

    # Home directories
    mkdir -p $out/root
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: attrs: "mkdir -p $out${attrs.home}") nonRootUsers
    )}

    # PAM configuration
    mkdir -p $out/etc/pam.d

    cat > $out/etc/pam.d/sudo <<'PAMEOF'
    ${pamSudo}
    PAMEOF

    cat > $out/etc/pam.d/su <<'PAMEOF'
    ${pamSu}
    PAMEOF

    cat > $out/etc/pam.d/system-auth <<'PAMEOF'
    ${pamSystemAuth}
    PAMEOF

    cat > $out/etc/pam.d/login <<'PAMEOF'
    ${pamLogin}
    PAMEOF

    # Sudoers configuration
    mkdir -p $out/etc/sudoers.d

    cat > $out/etc/sudoers.d/wheel <<'SUDOEOF'
    ${sudoersWheel}
    SUDOEOF

    chmod 440 $out/etc/sudoers.d/wheel
  ''
