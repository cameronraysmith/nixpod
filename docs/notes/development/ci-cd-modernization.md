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
  google_cloud_secretmanager:
    env_sync:
      path: projects/{{.gcp_project_id}}/secrets
```

Secrets accessed in justfile via `teller run -s -- env`.

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

Create `.github/actions/setup-nix/action.yml`:
```yaml
name: 'Setup Nix'
description: 'Install Nix with caching'

inputs:
  installer:
    description: 'Installation type: full (with space reclaim) or quick'
    default: 'full'
  cachix-cache-name:
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

    - name: Install Nix
      uses: DeterminateSystems/nix-installer-action@main
      with:
        extra-conf: |
          extra-platforms = aarch64-linux
          system-features = nixos-test benchmark big-parallel kvm

    - name: Setup Cachix
      if: inputs.cachix-cache-name != ''
      uses: cachix/cachix-action@v15
      with:
        name: ${{ inputs.cachix-cache-name }}
        authToken: ${{ inputs.cachix-auth-token }}
```

### Benefits

- Space reclamation on Linux runners (removes Android SDK, CodeQL, etc.)
- Consistent Nix configuration across all workflows
- Optional Cachix integration
- Platform-specific optimizations

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

### GitGuardian vs gitleaks

Current workflow uses GitGuardian for secret scanning.
Consider keeping both during transition, then consolidate to gitleaks for local pre-commit + CI scanning.
