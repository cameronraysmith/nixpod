# Per-arch image push and manifest assembly using skopeo (nix: transport) and crane
# mkPushImage: push a single-arch image to the registry with arch-suffixed tag
# mkManifest: assemble a manifest list from already-pushed per-arch images via crane
{ ... }:
{
  perSystem =
    {
      pkgs,
      lib,
      system,
      ...
    }:
    let
      inherit (pkgs)
        writeShellApplication
        coreutils
        crane
        jq
        ;

      # Map nix system identifiers to OCI architecture names, handling both
      # linux and darwin systems (darwin builds target linux containers)
      systemToArch =
        let
          linuxSystem =
            if pkgs.stdenv.isDarwin then builtins.replaceStrings [ "-darwin" ] [ "-linux" ] system else system;
        in
        {
          "x86_64-linux" = "amd64";
          "aarch64-linux" = "arm64";
        }
        .${linuxSystem};

      craneExe = lib.getExe crane;
      jqExe = lib.getExe jq;
    in
    {
      _module.args.mkPushImage =
        {
          image,
          name,
          registry,
          repo,
          version,
          tags ? [ ],
          branch ? "main",
          skopeo,
        }:
        let
          arch = systemToArch;
          archTag = "${version}-${arch}";
          fullRepo = "${registry}/${repo}";
          skopeoExe = lib.getExe skopeo;

          # Only arch-qualified tags: unqualified tags (version, latest) belong to manifest assembly
          archTags = map (t: "${t}-${arch}") (lib.filter (t: t != "") tags);
        in
        writeShellApplication {
          name = "push-${name}";
          runtimeInputs = [
            skopeo
            crane
            jq
            coreutils
          ];

          text = ''
            function cleanup {
              set -x
              ${skopeoExe} logout "${registry}" || true
              ${craneExe} auth logout "${registry}" || true
            }
            trap cleanup EXIT

            set -x

            if [[ ! -f "/etc/containers/policy.json" && ! -f "$HOME/.config/containers/policy.json" ]]; then
              mkdir -p "$HOME/.config/containers"
              install -Dm444 "${skopeo.policy}/default-policy.json" "$HOME/.config/containers/policy.json"
            fi

            set +x
            echo "Logging in to ${registry}"
            ${skopeoExe} login \
              --username "$GITHUB_ACTOR" \
              --password "$GITHUB_TOKEN" \
              "${registry}"
            ${craneExe} auth login "${registry}" \
              --username "$GITHUB_ACTOR" \
              --password "$GITHUB_TOKEN"
            set -x

            echo "Pushing ${arch} image to ${fullRepo}:${archTag}"
            ${skopeoExe} copy \
              --dest-creds "$GITHUB_ACTOR:$GITHUB_TOKEN" \
              "nix:${image}" \
              "docker://${fullRepo}:${archTag}"

            ${lib.optionalString (archTags != [ ]) (
              lib.concatMapStringsSep "\n" (tag: ''
                echo "Tagging ${fullRepo}:${archTag} as ${fullRepo}:${tag}"
                ${craneExe} tag "${fullRepo}:${archTag}" "${tag}"
              '') archTags
            )}

            set +x
            echo "Successfully pushed ${arch} image for ${name}"
            echo "Primary: ${fullRepo}:${archTag}"
            ${lib.optionalString (archTags != [ ]) (
              lib.concatMapStringsSep "\n" (tag: ''
                echo "  Also tagged: ${fullRepo}:${tag}"
              '') archTags
            )}
          '';
        };

      _module.args.mkManifest =
        {
          name,
          registry,
          repo,
          version,
          tags ? [ ],
          branch ? "main",
          arches ? [
            "amd64"
            "arm64"
          ],
        }:
        let
          fullRepo = "${registry}/${repo}";

          allTags = [
            version
          ]
          ++ (lib.filter (t: t != "") tags)
          ++ (if branch == "main" then [ "latest" ] else [ ]);

          primaryTag = lib.head allTags;
        in
        writeShellApplication {
          name = "manifest-${name}";
          runtimeInputs = [
            crane
            jq
            coreutils
          ];

          text = ''
            function cleanup {
              set -x
              ${craneExe} auth logout "${registry}" || true
            }
            trap cleanup EXIT

            set +x
            echo "Logging in to ${registry}"
            ${craneExe} auth login "${registry}" \
              --username "$GITHUB_ACTOR" \
              --password "$GITHUB_TOKEN"
            set -x

            declare -A DIGESTS
            ${lib.concatMapStringsSep "\n" (arch: ''
              echo "Reading digest for ${fullRepo}:${version}-${arch}"
              DIGESTS["${arch}"]=$(${craneExe} digest "${fullRepo}:${version}-${arch}")
              echo "  ${arch}: ''${DIGESTS["${arch}"]}"
            '') arches}

            echo "Creating multi-arch manifest list: ${fullRepo}:${primaryTag}"
            ${craneExe} index append \
              ${
                lib.concatMapStringsSep " \\\n          " (
                  arch: ''-m "${fullRepo}@''${DIGESTS["${arch}"]}"''
                ) arches
              } \
              -t "${fullRepo}:${primaryTag}"

            ${lib.concatMapStringsSep "\n" (tag: ''
              echo "Tagging ${fullRepo}:${primaryTag} as ${fullRepo}:${tag}"
              ${craneExe} tag "${fullRepo}:${primaryTag}" "${tag}"
            '') (lib.tail allTags)}

            set +x
            echo "Successfully created multi-arch manifest for ${name}"
            echo "Manifest: ${fullRepo}:${primaryTag}"
            ${craneExe} manifest "${fullRepo}:${primaryTag}" | ${jqExe} .
            echo "Tags: ${toString allTags}"
          '';
        };
    };
}
