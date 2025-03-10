{
  pkgs,
  preSudoImage,
}:
let
  configSudoSystem = pkgs.runCommand "config-sudo" { } (''
    mkdir -p $out/etc/pam.d/backup

    cat > $out/etc/pam.d/sudo <<EOF
    #%PAM-1.0
    auth        sufficient  pam_rootok.so
    auth        sufficient  pam_permit.so
    account     sufficient  pam_permit.so
    account     required    pam_warn.so
    session     required    pam_permit.so
    password    sufficient  pam_permit.so
    EOF

    cat > $out/etc/pam.d/su <<EOF
    #%PAM-1.0
    auth        sufficient  pam_rootok.so
    auth        sufficient  pam_permit.so
    account     sufficient  pam_permit.so
    account     required    pam_warn.so
    session     required    pam_permit.so
    password    sufficient  pam_permit.so
    EOF

    cat > $out/etc/pam.d/system-auth <<EOF
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

    cat > $out/etc/pam.d/login <<EOF
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

    cat >> $out/etc/sudoers <<EOF
    root     ALL=(ALL:ALL)    NOPASSWD:SETENV: ALL
    %wheel  ALL=(ALL:ALL)    NOPASSWD:SETENV: ALL
    EOF
  '');
in
pkgs.dockerTools.buildImage {
  name = "sudoimage";
  tag = "latest";
  fromImage = preSudoImage;
  compressor = "none";

  copyToRoot = configSudoSystem;
}
