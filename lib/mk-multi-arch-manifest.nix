# Multi-arch manifest builder using skopeo (nix: transport) and crane (manifest lists)
# Single-arch builds auto-detected and skip manifest list creation
{
  lib,
  writeShellApplication,
  coreutils,
  crane,
  jq,
}:
{
  images,
  name,
  registry,
  version,
  tags ? [ ],
  branch ? "main",
  skopeo,
}:
let
  # Tags: version first, then explicit tags or "latest" on main branch
  parsedTags = [
    version
  ]
  ++ (if tags != [ ] then tags else (if branch == "main" then [ "latest" ] else [ ]));
  isSingleArch = lib.length (lib.attrNames images) == 1;
  systemToArch = {
    "x86_64-linux" = "amd64";
    "aarch64-linux" = "arm64";
  };

  # Single-arch: push to primary tag; multi-arch: push with arch suffix, then create manifest list
  archImages = lib.mapAttrs' (
    system: image:
    let
      arch = systemToArch.${system};
      primaryTag = lib.head parsedTags;
    in
    lib.nameValuePair arch {
      inherit system image arch;
      tag = if isSingleArch then primaryTag else "${version}-${arch}";
      uri = "${registry.name}/${registry.repo}:${
        if isSingleArch then primaryTag else "${version}-${arch}"
      }";
    }
  ) images;

  manifestName = "${registry.name}/${registry.repo}:${lib.head parsedTags}";
  repoBase = "${registry.name}/${registry.repo}";

  skopeoExe = lib.getExe skopeo;
  craneExe = lib.getExe crane;
  jqExe = lib.getExe jq;

in
assert lib.assertMsg (images != { }) "At least one image must be provided";
assert lib.assertMsg (parsedTags != [ ]) "At least one tag must be set";

writeShellApplication {
  name = "multi-arch-manifest-${name}";
  runtimeInputs = [
    skopeo
    crane
    jq
    coreutils
  ];

  text = ''
    function cleanup {
      set -x
      ${skopeoExe} logout "${registry.name}" || true
      ${craneExe} auth logout "${registry.name}" || true
    }
    trap cleanup EXIT

    set -x

    if [[ ! -f "/etc/containers/policy.json" && ! -f "$HOME/.config/containers/policy.json" ]]; then
      mkdir -p "$HOME/.config/containers"
      install -Dm444 "${skopeo.policy}/default-policy.json" "$HOME/.config/containers/policy.json"
    fi

    set +x
    echo "Logging in to ${registry.name}"
    ${skopeoExe} login \
      --username "${registry.username}" \
      --password "${registry.password}" \
      "${registry.name}"
    ${craneExe} auth login "${registry.name}" \
      --username "${registry.username}" \
      --password "${registry.password}"
    set -x

    declare -A PUSHED_DIGESTS
    ${lib.concatMapStringsSep "\n" (archImage: ''
      echo "Pushing ${archImage.arch} image to ${archImage.uri}"
      DIGESTFILE=$(mktemp)
      ${skopeoExe} copy \
        --digestfile "$DIGESTFILE" \
        --dest-creds "${registry.username}:${registry.password}" \
        "nix:${archImage.image}" \
        "docker://${archImage.uri}"
      PUSHED_DIGESTS["${archImage.arch}"]=$(cat "$DIGESTFILE")
      rm "$DIGESTFILE"
      echo "Pushed ${archImage.arch} with digest: ''${PUSHED_DIGESTS["${archImage.arch}"]}"
    '') (lib.attrValues archImages)}

    ${lib.optionalString (!isSingleArch) ''
      echo "Creating multi-arch manifest list: ${manifestName}"
      ${craneExe} index append \
        ${
          lib.concatMapStringsSep " \\\n            " (
            archImage: ''-m "${repoBase}@''${PUSHED_DIGESTS["${archImage.arch}"]}"''
          ) (lib.attrValues archImages)
        } \
        -t "${manifestName}"

      set +x
      echo "Manifest: ${manifestName}"
      ${craneExe} manifest "${manifestName}" | ${jqExe} .
      echo "Tags: ${toString parsedTags}"
      set -x
    ''}

    ${lib.concatMapStringsSep "\n" (tag: ''
      ${craneExe} tag \
        "${registry.name}/${registry.repo}:${lib.head parsedTags}" \
        "${tag}"
    '') (lib.tail parsedTags)}

    set +x
    ${
      if isSingleArch then
        ''
          echo "Successfully pushed single-arch image for ${name}"
        ''
      else
        ''
          echo "Successfully pushed multi-arch manifest for ${name}"
        ''
    }
    echo "Available at: ${registry.name}/${registry.repo}:${lib.head parsedTags}"
    ${lib.concatMapStringsSep "\n" (tag: ''
      echo "  Also tagged: ${registry.name}/${registry.repo}:${tag}"
    '') (lib.tail parsedTags)}
  '';
}
