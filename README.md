<div align="center">

# nixpod

<a href="https://nix.dev/concepts/flakes" target="_blank">
	<img alt="Nix Flakes Ready" src="https://img.shields.io/static/v1?logo=nixos&logoColor=d8dee9&label=Nix%20Flakes&labelColor=5e81ac&message=In%20Containers&color=d8dee9&style=for-the-badge">
</a>

[![CI][ci-badge]][ci-link]

**containerized nix + home-manager development environments**

</div>

---

## What this provides

Containerized multi-user Nix development environments for platforms where NixOS cannot be used directly.
Four container variants ship prebuilt multi-arch images (x86_64, aarch64) to `ghcr.io`, each with the Nix daemon, s6-overlay process supervision, and home-manager user configuration.

| Variant | Purpose | User | Port |
|---------|---------|------|------|
| **nixpod** | General development | root (uid 0) | -- |
| **ghanix** | GitHub Actions runners | runner (uid 1001) | -- |
| **codenix** | code-server IDE | jovyan (uid 1000) | 8888 |
| **jupnix** | JupyterLab | jovyan (uid 1000) | 8888 |

<details>
<summary>Variant details</summary>

The *nixpod* container is the base variant with home-manager activated for root, intended for general-purpose development and debugging including scenarios like Kubernetes ephemeral containers.

The *ghanix* container is configured for GitHub Actions self-hosted runners with the runner user and includes the atuin daemon service.

The *codenix* container runs code-server on port 8888 with the jovyan user, includes VS Code extension installation and home-manager activation via s6 init scripts, and the atuin daemon.

The *jupnix* container runs JupyterLab on port 8888 with the jovyan user and includes the atuin daemon and home-manager activation.

All variants share a common base image built by `modules/containers/build-image.nix` with four ordered layers (base utilities, Nix daemon, s6-overlay, Nix configuration) plus a variant-specific customization layer.

</details>

## Quick start

Pull and run a prebuilt image:

```bash
docker pull ghcr.io/cameronraysmith/nixpod:latest
docker run -it --rm ghcr.io/cameronraysmith/nixpod:latest
```

Build from source and load into the local Docker daemon:

```bash
nix run .#load-nixpod
```

This uses skopeo with the nix2container transport to copy the image directly, without producing a full tarball.
On macOS, the loader automatically targets the corresponding Linux architecture.

<details>
<summary>Building containers on macOS (Apple Silicon)</summary>

Building container images requires a Linux builder since nix2container produces Linux derivations.
On Apple Silicon Macs, [nix-rosetta-builder](https://github.com/cpick/nix-rosetta-builder) provides an `x86_64-linux` and `aarch64-linux` builder via a lightweight Linux VM using Rosetta 2 translation.

To set it up, add the flake input and import the nix-darwin module:

```nix
# flake.nix
inputs.nix-rosetta-builder.url = "github:cpick/nix-rosetta-builder";
```

Then enable it in your nix-darwin configuration:

```nix
{
  imports = [ inputs.nix-rosetta-builder.darwinModules.default ];

  nix-rosetta-builder = {
    enable = true;
    onDemand = true;
    cores = 12;
    memory = "48GiB";
    diskSize = "500GiB";
  };
}
```

The `onDemand` option powers off the VM when idle to save resources.
Adjust `cores`, `memory`, and `diskSize` to match available system resources.
See the [nix-rosetta-builder README](https://github.com/cpick/nix-rosetta-builder) for the full set of configuration options.

### First-time bootstrap

The nix-rosetta-builder VM image is an `aarch64-linux` NixOS system, so building it requires a Linux builder, which creates a chicken-and-egg problem on a fresh macOS system that has no Linux builder yet.

nix-darwin ships a native `nix.linux-builder` module that provisions a QEMU-based Linux VM.
This VM can build `aarch64-linux` derivations, which is sufficient to build the nix-rosetta-builder VM image.
The bootstrap uses this native builder as a temporary stepping stone.

**Step 1** — enable the native linux-builder and apply the configuration:

```nix
{
  nix.linux-builder.enable = true;
}
```

```bash
darwin-rebuild switch
```

This starts a QEMU VM that registers itself as a `nix.buildMachines` entry for `aarch64-linux` builds.

**Step 2** — with the native builder running, enable nix-rosetta-builder and disable the native one:

```nix
{
  imports = [ inputs.nix-rosetta-builder.darwinModules.default ];

  nix.linux-builder.enable = false;

  nix-rosetta-builder = {
    enable = true;
    onDemand = true;
    cores = 12;
    memory = "48GiB";
    diskSize = "500GiB";
  };
}
```

```bash
darwin-rebuild switch
```

The native linux-builder provides the `aarch64-linux` build capability needed to build the nix-rosetta-builder VM image during this second `darwin-rebuild switch`.
Once nix-rosetta-builder is running, it registers itself as the Linux builder and can rebuild its own VM image on future activations, so the native builder is no longer needed.

Setting `nix.linux-builder.enable = false` is permanent.
It prevents running two Linux VMs for the same purpose and triggers a nix-darwin cleanup activation that removes the native builder's working directory at `/var/lib/linux-builder`.
The native builder would only need to be re-enabled if nix-rosetta-builder were completely removed and reinstalled from scratch.

</details>

Enter the development shell:

```bash
nix develop
```

## Build commands

```bash
nix build                    # build default home-manager activation package
nix build .#nixpod           # build nixpod container (nix2container JSON manifest)
nix build .#codenix          # build code-server container
nix build .#ghanix           # build GitHub Actions runner container
nix build .#jupnix           # build JupyterLab container
nix run .#load-nixpod        # load nixpod into Docker daemon via skopeo
nix fmt                      # format nix files via treefmt (nixfmt)
nix flake check              # validate flake, run nix-unit tests and pre-commit checks
```

<details>
<summary>Justfile recipes</summary>

The justfile provides grouped convenience commands.
Run `just` to see all available recipes or `just -n <recipe>` for a dry run.

**Nix operations:** `just build`, `just check`, `just lint`, `just io`, `just update`, `just clean`

**Container lifecycle:** `just container-build`, `just container-load`, `just container-run`, `just container-push`, `just container-push-all`, `just container-build-all`

**CI helpers:** `just gh-ci-run`, `just gh-workflow-status`, `just gh-watch`, `just gh-logs`, `just gh-rerun`, `just gh-cancel`

**Secrets management:** `just show-secrets`, `just edit-secrets`, `just scan-secrets`, `just export-secrets`, `just validate-secrets`, and additional sops utilities

**Release management:** `just test-release`, `just preview-version`, `just release`

**Devpod operations:** `just pod`, `just devpod`, `just provider`

</details>

## Flake outputs

<details>
<summary>Output summary</summary>

**packages** (per system: aarch64-darwin, aarch64-linux, x86_64-darwin, x86_64-linux)

- `default` -- home-manager activation package
- `load-nixpod`, `load-ghanix`, `load-codenix`, `load-jupnix` -- scripts that load images into Docker
- `push-nixpod`, `push-ghanix`, `push-codenix`, `push-jupnix` -- push arch-qualified images to ghcr.io

*Linux-only packages* (aarch64-linux, x86_64-linux):

- `nixpod`, `ghanix`, `codenix`, `jupnix` -- nix2container JSON image manifests
- `container` -- alias for nixpod
- `nixpod-users` -- system user identity derivation (passwd, group, shadow, PAM)
- `s6-overlay-layer` -- s6-overlay filesystem layout

**apps** (per system)

- `load-nixpod`, `load-ghanix`, `load-codenix`, `load-jupnix` -- container loader apps
- `push-nixpod`, `push-ghanix`, `push-codenix`, `push-jupnix` -- per-arch image push apps
- `nixpodManifest`, `ghanixManifest`, `codenixManifest`, `jupnixManifest` -- multi-arch manifest assembly

**devShells**

- `default` -- development shell with build and operations tooling

**checks**

- `nix-unit` -- 12 evaluation-time tests for flake structure and container invariants
- `pre-commit` -- git-hooks.nix pre-commit checks
- `treefmt` -- treefmt formatting validation

**formatter** -- treefmt (nixfmt)

**homeModules** -- `default` home-manager module (atuin, git, neovim, starship, terminal, zsh with catppuccin theming)

**legacyPackages** -- `homeConfigurations` (root, jovyan, runner) and `containerMatrix` for CI matrix discovery

</details>

## Development

Enter the development shell with `nix develop` or via direnv if configured.
The shell provides:

- **build and CI:** just, act, nix-output-monitor, ratchet
- **secrets:** age, sops, ssh-to-age, gitleaks
- **release:** bun, nodejs (for semantic-release)
- **pre-commit hooks:** treefmt (nixfmt) and gitleaks secret scanning via git-hooks.nix

Format all Nix files with `nix fmt`.
Validate the flake and run pre-commit checks with `nix flake check`.

## Architecture

The project is built on Nix Flakes with flake-parts for modular output composition.
The flake uses import-tree to auto-discover flake-parts modules from the `modules/` directory, eliminating manual import lists.
Container images are constructed with nix2container's `buildImage` and `buildLayer` for deferred tar creation and efficient layer management.
s6-overlay provides process supervision within containers.
Home-manager user configurations use deferred module composition via the `flake.modules.homeManager.*` namespace.
Multi-arch publishing uses a decoupled push/manifest model: skopeo pushes per-arch images via the nix2container transport, then crane assembles multi-platform manifest lists.


## Acknowledgements

- [nix2container](https://github.com/nlewo/nix2container) -- deferred tar creation for container images
- [s6-overlay](https://github.com/just-containers/s6-overlay) -- process supervision in containers
- [flake-parts](https://github.com/hercules-ci/flake-parts) -- modular flake output composition
- [import-tree](https://github.com/vic/import-tree) -- auto-discovery of flake-parts modules
- [home-manager](https://github.com/nix-community/home-manager) -- declarative user environment configuration
- [nix-unit](https://github.com/nix-community/nix-unit) -- evaluation-time unit testing for Nix expressions
- [crane](https://github.com/google/go-containerregistry/tree/main/cmd/crane) -- multi-arch manifest assembly
- [nix-rosetta-builder](https://github.com/cpick/nix-rosetta-builder) -- Rosetta 2-accelerated Linux builder for Apple Silicon
- [catppuccin](https://github.com/catppuccin/nix) -- theming for terminal and editor configuration
- [nix-snapshotter](https://github.com/pdtpartners/nix-snapshotter) -- CRI-layer container integration
- [vanixiets](https://github.com/cameronraysmith/vanixiets) -- reference nix-darwin and home-manager patterns

[ci-badge]: https://github.com/cameronraysmith/nixpod/actions/workflows/ci.yaml/badge.svg
[ci-link]: https://github.com/cameronraysmith/nixpod/actions/workflows/ci.yaml
