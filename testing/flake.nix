{
  description = "Docker image with nix on top of debian:stable-slim";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: 
    let
      buildImageOnTopOfDebian = system: let

        pkgs = nixpkgs.legacyPackages.${system};

        # Pulling the debian:stable-slim base image
        debianBaseImage = pkgs.dockerTools.pullImage {
          imageName = "debian";
          imageDigest = "sha256:6fe30b9cb71d604a872557be086c74f95451fecd939d72afe3cffca3d9e60607";
          sha256 = "qKf0EzF6xbogv1SuEATFODoru+wCI+oE6gSTN3T2i/U=";
          finalImageName = "debian";
          finalImageTag = "stable-slim";
        };


        dockerImage = pkgs.dockerTools.buildLayeredImage {
          name = "trynix";
          tag = "latest";
          fromImage = debianBaseImage;

          config = {
            Env = [ "PATH=${pkgs.bash}/bin"]; 
            Cmd = [
              "bash"
              # "${pkgs.bash}/bin/bash"
              # "-c"
              # ''
              # mkdir -p /nix/var/nix/profiles/default && \
              # ln -sf ${pkgs.nix} /nix/var/nix/profiles/default
              # ''
            ];

          };

          # # Since you're installing Nix via determinate systems, we don't need to add Nix here
          # # But if you want other utilities, add them.
          contents = [
            pkgs.bash
            pkgs.curl
            pkgs.git
            pkgs.time
            pkgs.cacert
          ];

          extraCommands = ''
            # Set up the environment with the right tools available
            export PATH=${pkgs.curl}/bin:$PATH
            export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
  
            # Fetch the installer binary
            curl --proto '=https' --tlsv1.2 -sSf -o nix-installer \
            https://install.determinate.systems/nix/nix-installer-${system}
  
            # Make it executable
            chmod +x nix-installer

            # Execute the installer
            ./nix-installer install linux \
            --extra-conf "sandbox = false" \
            --init none \
            --no-confirm
          '';
        };
      in
        dockerImage;

    in {
      packages.x86_64-linux.dockerImage = buildImageOnTopOfDebian "x86_64-linux";
      packages.aarch64-linux.dockerImage = buildImageOnTopOfDebian "aarch64-linux";
    };
}




# {
#   description = "Docker image with nix";

#   inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

#   outputs = { self, nixpkgs }: 
#     let
#       buildImage = system: let
#         pkgs = nixpkgs.legacyPackages.${system};

#         dockerImage = pkgs.dockerTools.buildLayeredImage {
#           name = "trynix";
#           tag = "latest";

#           config.Cmd = [
#             "${pkgs.bash}/bin/bash"
#             "-c"
#             ''
#             mkdir -p /nix/var/nix/profiles/default && \
#             ln -sf ${pkgs.nix} /nix/var/nix/profiles/default && \
#             export PATH="$PATH:/nix/var/nix/profiles/default/bin"
#             ''
#           ];

#           contents = [
#             pkgs.bash
#             pkgs.curl
#             pkgs.git
#             pkgs.time
#             pkgs.nix
#           ];

#           # extraCommands = ''
#           # '';
#         };

#       in
#         dockerImage;

#     in {
#       packages.x86_64-linux.dockerImage = buildImage "x86_64-linux";
#       packages.aarch64-linux.dockerImage = buildImage "aarch64-linux";
#       packages.aarch64-darwin.dockerImage = buildImage "aarch64-darwin";
#     };
# }
