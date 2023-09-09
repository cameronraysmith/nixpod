<div align="center">

# nixpod home flake

<a href="https://nixos.wiki/wiki/Flakes" target="_blank">
	<img alt="Nix Flakes Ready" src="https://img.shields.io/static/v1?logo=nixos&logoColor=d8dee9&label=Nix%20Flakes&labelColor=5e81ac&message=In%20Containers&color=d8dee9&style=for-the-badge">
</a>

</div>

While this repository contains a [Nix flake](https://zero-to-nix.com/concepts/flakes), it essentially integrates a few parts of [srid/nixos-config](https://github.com/srid/nixos-config) into [juspay/nix-dev-home](https://github.com/juspay/nix-dev-home) that were integrated upstream in [juspay/nix-dev-home#7](https://github.com/juspay/nix-dev-home/pull/7), so you might prefer to look there.

The intention of this repository is to provide a reasonably ergonomic, if somewhat heavy-handed, drop-in configuration on any platform where the [nix](https://github.com/NixOS/nix) package manager is, or can be, installed. This is intended to include applications like [kubernetes ephemeral containers](https://kubernetes.io/docs/concepts/workloads/pods/ephemeral-containers/) via images like [netshoot](https://github.com/nicolaka/netshoot), which might be used for debugging purposes adjacent to otherwise minimal container images.

## Testing

If you have [just](https://github.com/casey/just) and the specified container `builder` installed on your `PATH` and available,

```bash
just testcontainer-run
```

should build the container image in [testing/Dockerfile](testing/Dockerfile) and run the flake in that image.
Note that just `just` will print help and you can run `just -n <command>` first for a dry run.
See comments in the [justfile](justfile) for additional details.

### macOS

If you have a container image manager like docker installed, you can probably

```bash
open -a Docker
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cargo install just
just testcontainer-run
```

however, please see [rust](https://www.rust-lang.org/tools/install) for details.

## Acknowledgements

- [DeterminateSystems/nix-installer](https://github.com/DeterminateSystems/nix-installer)
- [pdtpartners/nix-snapshotter](https://github.com/pdtpartners/nix-snapshotter)
- [snowfallorg](https://github.com/snowfallorg)
- [srid/nixos-config](https://github.com/srid/nixos-config)
