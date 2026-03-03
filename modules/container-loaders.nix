{
  self,
  inputs,
  ...
}:
{
  perSystem =
    {
      pkgs,
      inputs',
      self',
      system,
      ...
    }:
    let
      skopeo = inputs'.nix2container.packages.skopeo-nix2container;
      targetSystem =
        if pkgs.stdenv.isDarwin then builtins.replaceStrings [ "-darwin" ] [ "-linux" ] system else system;

      mkContainerLoader =
        name: packageName:
        let
          image = self.packages.${targetSystem}.${packageName};
        in
        pkgs.writeShellApplication {
          name = "load-${name}";
          runtimeInputs = [ skopeo ];
          text = ''
            echo "Loading ${name} (${targetSystem}) into Docker daemon..."
            skopeo --insecure-policy copy \
              "nix:${image}" \
              "docker-daemon:${image.imageName}:${image.imageTag}"
            echo "Done. Run: docker run -it --rm ${image.imageName}:${image.imageTag}"
          '';
        };
    in
    {
      packages = {
        load-nixpod = mkContainerLoader "nixpod" "container";
        load-ghanix = mkContainerLoader "ghanix" "ghanix";
        load-codenix = mkContainerLoader "codenix" "codenix";
        load-jupnix = mkContainerLoader "jupnix" "jupnix";
      };

      apps = {
        load-nixpod = {
          type = "app";
          program = "${self'.packages.load-nixpod}/bin/load-nixpod";
        };
        load-ghanix = {
          type = "app";
          program = "${self'.packages.load-ghanix}/bin/load-ghanix";
        };
        load-codenix = {
          type = "app";
          program = "${self'.packages.load-codenix}/bin/load-codenix";
        };
        load-jupnix = {
          type = "app";
          program = "${self'.packages.load-jupnix}/bin/load-jupnix";
        };
      };
    };
}
