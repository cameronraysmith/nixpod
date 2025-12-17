# Container build refactoring

This document describes the planned migration from `dockerTools.buildLayeredImageWithNixDb` to nix2container for improved build efficiency and reduced store bloat.

## Current architecture

The current `containers/nix.nix` wraps `dockerTools.buildLayeredImageWithNixDb` with:
- s6-overlay extraction via `fakeRootCommands`
- Multi-user support (root/jovyan/runner) with uid/gid mapping
- `storeOwner` configuration for image user and /nix ownership
- Nix daemon configuration via `nixConf`
- Sudo wrapper setup with setuid bit

This approach writes complete layer tarballs to the Nix store during build, then copies them to the registry.
For images with many layers (maxLayers=111), this creates significant store bloat and slow iterative builds.

## nix2container approach

nix2container defers tarball generation entirely.
It generates JSON manifests with pre-computed layer digests, synthesizing tarballs only at push time via patched skopeo.

Key benefits:
- No tarballs written to Nix store (massive space savings)
- Skopeo can skip already-pushed layers without rebuilding
- Fast rebuild/repush cycles (~1.8s vs ~10s for dockerTools)
- Same popularity-based layer algorithm for cache optimization

## API mapping

### buildImage parameters

The nix2container `buildImage` function maps to current usage as follows.

| Current (dockerTools) | nix2container |
|-----------------------|---------------|
| `name`, `tag` | Same |
| `maxLayers` | Same (popularity algorithm) |
| `contents` | `copyToRoot` |
| `uid`, `gid`, `uname`, `gname` | `perms` entries + `config.User` |
| `fakeRootCommands` | Pre-extract to derivation + `perms` |
| `config.Entrypoint` | `config.entrypoint` (camelCase) |
| `config.Cmd` | `config.cmd` |
| `config.Env` | Same |
| `fromImage` | `pullImage` or `pullImageFromManifest` |
| `enableFakechroot` | Not needed (perms replace) |

### Nix database initialization

Current implicit initialization via `buildLayeredImageWithNixDb` becomes explicit:
```nix
nix2container.buildImage {
  initializeNixDatabase = true;
  nixUid = 0;
  nixGid = 0;
}
```

## Migration steps

### Step 1: Add nix2container input

```nix
inputs.nix2container = {
  url = "github:nlewo/nix2container";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

### Step 2: Extract s6-overlay to derivation

Current approach extracts in fakeRootCommands:
```nix
fakeRootCommands = ''
  ${pkgs.gnutar}/bin/tar -C / -Jxpf ${s6-overlay}
  ${pkgs.gnutar}/bin/tar -C / -Jxpf ${s6-overlay-arch}
''
```

Migrated approach pre-extracts into a derivation:
```nix
s6-overlay-extracted = pkgs.runCommand "s6-overlay" { } ''
  mkdir -p $out
  ${pkgs.gnutar}/bin/tar -C $out -Jxpf ${s6-overlay}
  ${pkgs.gnutar}/bin/tar -C $out -Jxpf ${s6-overlay-arch}
'';
```

Then include via `copyToRoot = [ baseSystem s6-overlay-extracted ];`.

### Step 3: Replace fakeRootCommands with perms

Current ownership setup:
```nix
fakeRootCommands = ''
  chown -R jovyan:wheel /home/jovyan
  chown -R runner:wheel /home/runner
  chmod 775 /home/jovyan
  chmod 775 /home/runner
''
```

Migrated perms array:
```nix
perms = [
  {
    path = userDirectories;
    regex = "/home/jovyan";
    mode = "0755";
    uid = 1000;
    gid = 0;
    uname = "jovyan";
    gname = "wheel";
  }
  {
    path = userDirectories;
    regex = "/home/runner";
    mode = "0755";
    uid = 1001;
    gid = 0;
    uname = "runner";
    gname = "wheel";
  }
];
```

The `perms` entries set ownership during tar layer creation without needing fakeroot.

### Step 4: Extract passwd/group generation

Move user configuration into separate derivation following the nix2container `nix-user.nix` pattern:
```nix
mkUsers = pkgs.runCommand "mkUsers" { } ''
  mkdir -p $out/etc
  cat > $out/etc/passwd <<EOF
  root:x:0:0:System administrator:/root:${pkgs.bashInteractive}/bin/bash
  jovyan:x:1000:100:Jupyter user:/home/jovyan:${pkgs.bashInteractive}/bin/bash
  runner:x:1001:121:GitHub runner:/home/runner:${pkgs.bashInteractive}/bin/bash
  nobody:x:65534:65534:Unprivileged:/var/empty:/bin/false
  EOF
  # ... similar for group, shadow
  mkdir -p $out/home/jovyan $out/home/runner
'';
```

### Step 5: Convert config format

Config fields are largely compatible but use camelCase:
```nix
config = {
  entrypoint = [ "/init" ];
  cmd = [ ];
  User = "${toString storeOwner.uid}:${toString storeOwner.gid}";
  Env = [
    "USER=${storeOwner.uname}"
    "HOME=${if storeOwner.uname == "root" then "/root" else "/home/${storeOwner.uname}"}"
    # ... rest of current Env
  ];
  ExposedPorts = {
    "8888/tcp" = { };
  };
};
```

### Step 6: Image distribution

nix2container provides passthru scripts:
- `copyToDockerDaemon` - load into local Docker
- `copyToPodman` - load into Podman
- `copyToRegistry` - push to registry via skopeo

## flocken integration

flocken remains orthogonal to the build backend.
The `mkDockerManifest` function works with nix2container outputs since both produce OCI-compliant images.

Multi-arch workflow:
1. Build per-system images with nix2container
2. Push each architecture via `copyToRegistry`
3. Create multi-arch manifest with flocken's `mkDockerManifest`

No changes needed to current manifest publishing logic.

## Layer composition strategies

### Popularity-based splitting (current approach)

```nix
nix2container.buildImage {
  maxLayers = 100;
  copyToRoot = [ ... ];
}
```

Store paths ranked by how many other paths depend on them.
Popular paths grouped into lower layers, frequently-changing paths isolated in upper layers.

### Explicit layer separation

For high-churn applications, define stable dependencies explicitly:
```nix
layers = [
  (nix2container.buildLayer {
    deps = [ pkgs.nix pkgs.bash pkgs.coreutils ];
  })
];
# Application code in implicit top layer
```

The explicit layer's closure is excluded from the implicit application layer.

## Base image handling

### Current sudoImage approach

Currently builds a layered base with pam/sudo via dockerTools:
```nix
pamImage = pkgs.dockerTools.buildImage { ... };
suImage = pkgs.dockerTools.buildImage { fromImage = pamImage; ... };
preSudoImage = pkgs.dockerTools.buildImage { fromImage = pamImage; ... };
sudoImage = import ./containers/sudoimage.nix { ... };
```

### Migrated approach with manifest

Use `pullImageFromManifest` for deterministic base image:
```nix
baseImage = nix2container.pullImageFromManifest {
  imageName = "library/alpine";
  imageManifest = ./alpine-manifest.json;
  os = "linux";
  arch = "amd64";
};
```

Generate manifest lockfile:
```bash
nix run .#baseImage.getManifest > alpine-manifest.json
```

Alternatively, build pam/sudo as nix2container layers and compose.

## Testing strategy

1. Build nixpod with nix2container alongside current implementation
2. Compare image contents via `skopeo inspect`
3. Verify s6-overlay services start correctly
4. Test home-manager activation inside container
5. Confirm Nix commands work (nix build, nix develop)
6. Benchmark build/push times vs dockerTools

## Implementation order

1. Add nix2container flake input
2. Create `buildMultiUserNixImage2` as parallel implementation
3. Migrate s6-overlay extraction to derivation
4. Migrate user/group setup to perms pattern
5. Build single container variant (nixpod) with nix2container
6. Compare outputs and timing
7. Migrate remaining variants (ghanix, codenix, jupnix)
8. Update CI to use new build functions
9. Remove dockerTools implementation
