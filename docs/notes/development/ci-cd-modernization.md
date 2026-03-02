# CI/CD modernization

This document describes patterns from typescript-nix-template to adopt for improving nixpod-home's CI/CD infrastructure, secrets management, and flake organization.

## Import-tree module pattern

### Current approach

nixpod-home defines flake configuration inline in `flake.nix` with a single `./home` import:
```nix
outputs = inputs@{ self, ... }:
  inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = import inputs.systems;
    imports = [
      inputs.nixos-flake.flakeModule
      ./home
    ];
    perSystem = { ... }: { ... };
  };
```

### Migrated approach with import-tree

Add the import-tree input:
```nix
inputs.import-tree.url = "github:vic/import-tree";
```

Restructure to use `modules/` directory:
```nix
outputs = inputs@{ flake-parts, ... }:
  flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
```

Create focused module files:

| File | Purpose |
|------|---------|
| `modules/systems.nix` | System declarations |
| `modules/dev-shell.nix` | Development shell configuration |
| `modules/formatting.nix` | treefmt-nix and pre-commit hooks |
| `modules/home.nix` | Home-manager module exports |
| `modules/containers.nix` | Container variant definitions |
| `modules/manifests.nix` | flocken manifest builders |

Each module exports a fragment that flake-parts combines automatically.

Example `modules/systems.nix`:
```nix
{
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];
}
```

Example `modules/dev-shell.nix`:
```nix
{ inputs, ... }:
{
  perSystem = { pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      name = "nixpod";
      nativeBuildInputs = with pkgs; [
        act
        just
        ratchet
        age
        sops
        ssh-to-age
        gitleaks
      ];
    };
  };
}
```

## Secrets management with sops-nix

### Current approach with teller

nixpod-home uses teller for secrets via `.teller.yml`:
```yaml
providers:
  google_secretmanager_1:
    kind: google_secretmanager
    maps:
    - id: gsm
      path: projects/{{ get_env(name="GCP_PROJECT_ID", default="default") }}
      keys:
        CACHIX_AUTH_TOKEN: ==
        ARTIFACT_REGISTRY_PASSWORD: ==
        FAST_FORWARD_PAT: ==
```

The provider kind is `google_secretmanager` (not `google_cloud_secretmanager`), and secrets are configured via a `maps` structure with explicit key mappings rather than `env_sync.path`.
Secrets are accessed in the justfile via `teller run -s -- env`.

### Migrated approach with sops-nix and age

Create `.sops.yaml` for age key configuration:
```yaml
keys:
  - &dev age1...your-dev-public-key
  - &ci age1...your-ci-public-key

creation_rules:
  - path_regex: vars/.*\.yaml$
    key_groups:
      - age:
          - *dev
          - *ci
```

Create encrypted secrets file `vars/shared.yaml`:
```bash
sops vars/shared.yaml
# Editor opens - add secrets in YAML format
# CACHIX_AUTH_TOKEN: your-token-here
# CACHIX_CACHE_NAME: sciexp
```

Add `.gitleaksignore` for allowlisted patterns:
```
# Age public keys in documentation are safe
<commit>:<file>:generic-api-key:<line>
```

Integrate with pre-commit:
```nix
# modules/formatting.nix
pre-commit.settings.hooks.gitleaks = {
  enable = true;
  entry = "${pkgs.gitleaks}/bin/gitleaks protect --staged --verbose";
};
```

### CI integration

Pass age key as GitHub secret `SOPS_AGE_KEY`, then decrypt in workflows:
```yaml
- name: Decrypt secrets
  run: |
    mkdir -p ~/.config/sops/age
    echo "${{ secrets.SOPS_AGE_KEY }}" > ~/.config/sops/age/keys.txt
    sops -d vars/shared.yaml > vars/decrypted.yaml
```

## Cached CI job action

### Pattern overview

The `cached-ci-job` action avoids re-running expensive operations by hashing source files and caching job results.

The example below is a simplified illustration of the concept.
The actual vanixiets implementation is significantly more sophisticated, with additional inputs for workflow file hashing, result directory management, and edge case handling around cache restoration.

Create `.github/actions/cached-ci-job/action.yaml`:
```yaml
name: 'Cached CI Job'
description: 'Content-addressed job result caching'

inputs:
  check-name:
    description: 'Unique job identifier'
    required: true
  hash-sources:
    description: 'Glob patterns for cache key computation'
    default: '**/*.nix flake.lock justfile'
  force-run:
    description: 'Bypass cache and force execution'
    default: 'false'

outputs:
  should-run:
    description: 'Whether the job should execute'
    value: ${{ steps.check.outputs.should-run }}

runs:
  using: 'composite'
  steps:
    - name: Compute content hash
      id: hash
      shell: bash
      run: |
        SOURCES="${{ inputs.hash-sources }}"
        WORKFLOW_FILE="${{ github.workflow_ref }}"
        HASH=$(git ls-files -z $SOURCES | xargs -0 git hash-object | sort | sha256sum | cut -d' ' -f1)
        echo "hash=$HASH" >> $GITHUB_OUTPUT

    - name: Check cache
      id: cache
      uses: actions/cache@v4
      with:
        path: .cache/job-results
        key: ci-${{ inputs.check-name }}-${{ steps.hash.outputs.hash }}

    - name: Determine execution
      id: check
      shell: bash
      run: |
        if [[ "${{ inputs.force-run }}" == "true" ]]; then
          echo "should-run=true" >> $GITHUB_OUTPUT
        elif [[ "${{ steps.cache.outputs.cache-hit }}" == "true" ]]; then
          echo "should-run=false" >> $GITHUB_OUTPUT
        else
          echo "should-run=true" >> $GITHUB_OUTPUT
        fi
```

### Usage in workflows

```yaml
- name: Check cache
  id: cache
  uses: ./.github/actions/cached-ci-job
  with:
    check-name: nix-build
    hash-sources: '**/*.nix flake.lock'

- name: Build
  if: steps.cache.outputs.should-run == 'true'
  run: nix build

- name: Mark success
  if: steps.cache.outputs.should-run == 'true'
  run: mkdir -p .cache/job-results && touch .cache/job-results/success
```

## Setup-nix action

### Consolidated Nix installation

Create `.github/actions/setup-nix/action.yml`.
The vanixiets reference implementation uses `cachix/install-nix-action` (not `DeterminateSystems/nix-installer-action`) for Nix installation, `cachix/cachix-action@v16` (not v15), and the parameter is named `cachix-name` (not `cachix-cache-name`).
The action also supports macOS CI runners with dedicated space reclamation (removing Xcode, Simulator, Homebrew caches) and post-run disk reporting.

Simplified example:
```yaml
name: 'Setup Nix'
description: 'Install Nix with caching'

inputs:
  installer:
    description: 'Installation type: full (with space reclaim) or quick'
    default: 'full'
  system:
    description: 'Nix system to configure (e.g., x86_64-linux, aarch64-darwin)'
    required: true
  enable-cachix:
    description: 'Enable cachix binary cache'
    default: 'false'
  cachix-name:
    description: 'Cachix cache name'
    required: false
  cachix-auth-token:
    description: 'Cachix auth token'
    required: false

runs:
  using: 'composite'
  steps:
    - name: Reclaim space (linux)
      if: runner.os == 'Linux' && inputs.installer == 'full'
      uses: wimpysworld/nothing-but-nix@main
      with:
        hatchet-protocol: cleave
        mnt-safe-haven: '4096'

    - name: Reclaim space (darwin)
      if: runner.os == 'macOS' && inputs.installer == 'full'
      shell: bash
      run: |
        sudo rm -rf /Applications/Xcode_* /Library/Developer/CoreSimulator \
          /Users/runner/.dotnet /Users/runner/.rustup /Users/runner/hostedtoolcache &

    - name: Install Nix
      uses: cachix/install-nix-action@v31
      with:
        extra_nix_config: |
          sandbox = true
          system = ${{ inputs.system }}

    - name: Setup magic-nix-cache
      if: inputs.installer == 'full'
      uses: DeterminateSystems/magic-nix-cache-action@main
      with:
        use-flakehub: false

    - name: Setup Cachix
      if: inputs.enable-cachix == 'true'
      uses: cachix/cachix-action@v16
      with:
        name: ${{ inputs.cachix-name }}
        authToken: ${{ inputs.cachix-auth-token }}
```

### Benefits

- Space reclamation on both Linux and macOS runners
- Consistent Nix configuration across all workflows
- Optional Cachix integration for binary caches
- magic-nix-cache-action for transparent binary cache sharing between CI jobs (uses GitHub Actions cache as a read-through Nix binary cache, requiring no Cachix setup for cross-job sharing)
- Platform-specific optimizations including macOS support

## Pre-commit hooks with treefmt-nix

### Configuration

```nix
# modules/formatting.nix
{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem = { pkgs, ... }: {
    treefmt = {
      projectRootFile = "flake.nix";
      programs.nixfmt.enable = true;
    };

    pre-commit.settings.hooks = {
      treefmt.enable = true;
      gitleaks = {
        enable = true;
        entry = "${pkgs.gitleaks}/bin/gitleaks protect --staged --verbose";
      };
    };
  };
}
```

### Development shell integration

```nix
devShells.default = pkgs.mkShell {
  shellHook = config.pre-commit.installationScript;
  packages = [ config.treefmt.build.wrapper ];
};
```

## Category-based CI matrix

### Problem

Large flakes with many outputs can exhaust disk space on single runners.

### Solution

Split builds by category:
```yaml
nix:
  strategy:
    matrix:
      include:
        - system: x86_64-linux
          category: packages
        - system: x86_64-linux
          category: checks
        - system: x86_64-linux
          category: devshells
```

Add justfile recipe:
```
ci-build-category system category:
  @case "{{category}}" in \
    packages) nix build .#packages.{{system}}.default ;; \
    checks) nix flake check ;; \
    devshells) nix develop -c true ;; \
  esac
```

## Nix-driven CI matrix discovery

### Problem

Hardcoded YAML matrices duplicate information that the flake already knows: which containers exist, which architectures each targets, and which manifests to publish.
Adding or removing a container requires updating both Nix code and workflow YAML.

### Solution

Export a `containerMatrix` flake output that CI evaluates at runtime to discover the build matrix dynamically.
This is a pure evaluation (no `--impure` needed) that returns structured JSON:

```nix
flake.containerMatrix = {
  build = lib.flatten (
    lib.mapAttrsToList (
      containerName: def:
      map (targetName: {
        container = containerName;
        target = targetName;
      }) (def.targets or defaultTargetNames)
    ) containerDefs
  );
  manifest = lib.attrNames containerDefs;
};
```

CI discovers the matrix in a setup job:
```yaml
- name: Discover container matrix from Nix
  id: matrix
  run: |
    BUILD=$(nix eval .#containerMatrix.build --json)
    MANIFEST=$(nix eval .#containerMatrix.manifest --json)
    echo "build=$BUILD" >> $GITHUB_OUTPUT
    echo "manifest=$MANIFEST" >> $GITHUB_OUTPUT
```

Downstream jobs consume the output as a dynamic matrix:
```yaml
build:
  needs: discover
  strategy:
    matrix:
      include: ${{ fromJSON(needs.discover.outputs.build-matrix) }}
```

Adding a new container or architecture only requires updating the Nix `containerDefs`; the CI workflow adapts automatically.

## Flake input update automation

Create `.github/workflows/update-flake-inputs.yaml`:
```yaml
name: Update flake inputs
on:
  schedule:
    - cron: '0 3,15 * * *'
  workflow_dispatch:

permissions:
  contents: write
  pull-requests: write

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: DeterminateSystems/nix-installer-action@main

      - name: Update flake.lock
        run: nix flake update

      - name: Create Pull Request
        uses: peter-evans/create-pull-request@v6
        with:
          commit-message: 'chore(deps): update flake inputs'
          title: 'chore(deps): update flake inputs'
          branch: flake-updates
          delete-branch: true
```

## Implementation order

1. Add pre-commit hooks with gitleaks
2. Implement cached-ci-job action
3. Create setup-nix composite action
4. Add sops-nix secrets alongside teller (parallel period)
5. Migrate secrets from teller to sops
6. Remove teller configuration
7. Restructure flake with import-tree modules
8. Add flake input update automation

## Compatibility notes

### teller migration path

Run teller and sops in parallel during migration:
1. Export secrets from teller: `teller export env > .secrets.env`
2. Encrypt with sops: `sops -e -i vars/shared.yaml`
3. Update workflows to use sops
4. Remove teller after validation

### Secret scanning with gitleaks

Secret scanning uses gitleaks as a git-hooks.nix pre-commit hook, replacing the previous GitGuardian CI job.
The hook runs `gitleaks protect --staged --verbose --redact` on every commit via the dev shell.
