{ pkgs
, suImage
}:
pkgs.dockerTools.buildImage {
  name = "sudoimage";
  tag = "latest";
  fromImage = suImage;
  compressor = "none";

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
}
