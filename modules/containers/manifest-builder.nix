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

      systemToArch = {
        "x86_64-linux" = "amd64";
        "aarch64-linux" = "arm64";
      };

      craneExe = lib.getExe crane;
      jqExe = lib.getExe jq;
    in
    {
      _module.args.mkPushImage =
        {
          image,
          name,
          registry,
          version,
          tags ? [ ],
          branch ? "main",
          skopeo,
        }:
        let
          arch = systemToArch.${system};
          archTag = "${version}-${arch}";
          repo = "${registry}/${name}";
          skopeoExe = lib.getExe skopeo;

          # Additional tags: version (without arch suffix), git SHA, git ref, latest on main
          allTags = [
            version
          ]
          ++ (lib.filter (t: t != "") tags)
          ++ (if branch == "main" then [ "latest" ] else [ ]);
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

            echo "Pushing ${arch} image to ${repo}:${archTag}"
            ${skopeoExe} copy \
              --dest-creds "$GITHUB_ACTOR:$GITHUB_TOKEN" \
              "nix:${image}" \
              "docker://${repo}:${archTag}"

            ${lib.concatMapStringsSep "\n" (tag: ''
              echo "Tagging ${repo}:${archTag} as ${repo}:${tag}"
              ${craneExe} tag "${repo}:${archTag}" "${tag}"
            '') allTags}

            set +x
            echo "Successfully pushed ${arch} image for ${name}"
            echo "Primary: ${repo}:${archTag}"
            ${lib.concatMapStringsSep "\n" (tag: ''
              echo "  Also tagged: ${repo}:${tag}"
            '') allTags}
          '';
        };

      _module.args.mkManifest =
        {
          name,
          registry,
          version,
          tags ? [ ],
          branch ? "main",
          arches ? [
            "amd64"
            "arm64"
          ],
        }:
        let
          repo = "${registry}/${name}";

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
              echo "Reading digest for ${repo}:${version}-${arch}"
              DIGESTS["${arch}"]=$(${craneExe} digest "${repo}:${version}-${arch}")
              echo "  ${arch}: ''${DIGESTS["${arch}"]}"
            '') arches}

            echo "Creating multi-arch manifest list: ${repo}:${primaryTag}"
            ${craneExe} index append \
              ${
                lib.concatMapStringsSep " \\\n          " (arch: ''-m "${repo}@''${DIGESTS["${arch}"]}"'') arches
              } \
              -t "${repo}:${primaryTag}"

            ${lib.concatMapStringsSep "\n" (tag: ''
              echo "Tagging ${repo}:${primaryTag} as ${repo}:${tag}"
              ${craneExe} tag "${repo}:${primaryTag}" "${tag}"
            '') (lib.tail allTags)}

            set +x
            echo "Successfully created multi-arch manifest for ${name}"
            echo "Manifest: ${repo}:${primaryTag}"
            ${craneExe} manifest "${repo}:${primaryTag}" | ${jqExe} .
            echo "Tags: ${toString allTags}"
          '';
        };
    };
}
