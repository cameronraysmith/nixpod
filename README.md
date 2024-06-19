<div align="center">

# nixpod home flake

<a href="https://nixos.wiki/wiki/Flakes" target="_blank">
	<img alt="Nix Flakes Ready" src="https://img.shields.io/static/v1?logo=nixos&logoColor=d8dee9&label=Nix%20Flakes&labelColor=5e81ac&message=In%20Containers&color=d8dee9&style=for-the-badge">
</a>

**[tl;dr](#experimenting)**

</div>

While this repository contains a [Nix flake](https://zero-to-nix.com/concepts/flakes), it essentially integrates a few parts of [srid/nixos-config](https://github.com/srid/nixos-config) into [juspay/nix-dev-home](https://github.com/juspay/nix-dev-home). These were merged upstream in [juspay/nix-dev-home#7](https://github.com/juspay/nix-dev-home/pull/7), so you might prefer to look there.

Using [home-manager](https://github.com/nix-community/home-manager), [nixpod](https://ghcr.io/cameronraysmith/nixpod) provides an ergonomic drop-in configuration on any platform where the [nix](https://github.com/NixOS/nix) package manager is already, or can be, [installed](https://nix.dev/install-nix.html). This is intended to include scenarios like those involving [kubernetes ephemeral containers](https://kubernetes.io/docs/concepts/workloads/pods/ephemeral-containers/) via images like [netshoot](https://github.com/nicolaka/netshoot), which might be used for debugging purposes adjacent to otherwise minimal container images.

## Testing

> [!NOTE]
> This repository previously supported building containers exclusively via [Containerfile](https://github.com/cameronraysmith/nixpod/blob/main/containers/Containerfile.debnix). Currently it uses [pkgs.dockerTools](https://nixos.org/manual/nixpkgs/stable/#sec-pkgs-dockerTools) and the Containerfiles are only retained for comparison. Other excellent tools for building container images with nix that may be supported in the future are [nix2container](https://github.com/nlewo/nix2container) and [nix-snapshotter](https://github.com/pdtpartners/nix-snapshotter).

### direnv and dev shell

If you have [direnv](https://github.com/direnv/direnv) installed and configured you probably know what to do. If you do not and you would like to use the [nix dev shell](https://nixos.wiki/wiki/Flakes#Super_fast_nix-shell), which will install [just](https://github.com/casey/just) using nix, you can execute `nix develop`.  If the [container `builder` specified in the justfile](justfile) is already installed on your `PATH` with necessary daemon running and available,

```bash
nix develop
just container_command_type="runflake" container-run
```

should pull or build the container image in [containers/Containerfile.debnix](./containers/Containerfile.debnix) and run the flake in that image. If you want to force a local rebuild run `just container-build`.
Note that just `just` will print help and you can run `just -n <command>` first for a dry run.
See comments in the [justfile](justfile) for additional details.

### macOS

If you have a container image manager compatible with macOS installed, such as docker or rancher desktop, and you prefer not to use the [nix dev shell](#direnv-and-dev-shell), you can probably (with docker desktop for example)

```bash
open -a Docker
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cargo install just
just container_command_type="runflake" container-run
```

however, please see [rust](https://www.rust-lang.org/tools/install) and [just](https://github.com/casey/just#installation) for details if you prefer another installation method like [homebrew](https://formulae.brew.sh/formula/just).

## Experimenting

If you want to simply run a distribution of this flake in a container image, you can execute

```bash
just container_type="container" container_command="zsh" container-run
```

### docker

If you're using docker as the `builder`, this will execute a series of commands like

```bash
docker pull ghcr.io/cameronraysmith/nixpod:latest
docker run -it --rm ghcr.io/cameronraysmith/nixpod:latest
```

See the [justfile](justfile) for details.

## Acknowledgements

- [DeterminateSystems/nix-installer](https://github.com/DeterminateSystems/nix-installer)
- [pdtpartners/nix-snapshotter](https://github.com/pdtpartners/nix-snapshotter)
- [snowfallorg](https://github.com/snowfallorg)
- [srid/nixos-config](https://github.com/srid/nixos-config)
