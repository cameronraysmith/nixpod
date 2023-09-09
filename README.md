<div align="center">

# nixpod home flake

<a href="https://nixos.wiki/wiki/Flakes" target="_blank">
	<img alt="Nix Flakes Ready" src="https://img.shields.io/static/v1?logo=nixos&logoColor=d8dee9&label=Nix%20Flakes&labelColor=5e81ac&message=In%20Containers&color=d8dee9&style=for-the-badge">
</a>

</div>

While this repository contains a [Nix flake](https://zero-to-nix.com/concepts/flakes), it essentially integrates a few parts of [srid/nixos-config](https://github.com/srid/nixos-config) into [juspay/nix-dev-home](https://github.com/juspay/nix-dev-home) that were integrated upstream in [juspay/nix-dev-home#7](https://github.com/juspay/nix-dev-home/pull/7), so you might prefer to look there.

The intention of this repository is to provide a reasonably ergonomic, if somewhat heavy-handed, drop-in configuration on any platform where the [nix](https://github.com/NixOS/nix) package manager is or can be installed, including things like [kubernetes ephemeral containers](https://kubernetes.io/docs/concepts/workloads/pods/ephemeral-containers/) using images like [netshoot](https://github.com/nicolaka/netshoot) that might be used for debugging purposes adjacent to otherwise minimal container images.

## Testing

If you have [just](https://github.com/casey/just) and the specified container `builder` installed on your `PATH`,

```bash
just testcontainer-run
```

Note that just `just` will print help and you can run `just -n <command>` first for a dry run.
See comments in the [justfile](justfile) for additional details.

## Acknowledgements

- [DeterminateSystems/nix-installer](https://github.com/DeterminateSystems/nix-installer)
- [pdtpartners/nix-snapshotter](https://github.com/pdtpartners/nix-snapshotter)
- [snowfallorg](https://github.com/snowfallorg)
- [srid/nixos-config](https://github.com/srid/nixos-config)
