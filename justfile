# Default command when 'just' is run without arguments
# Run 'just <command>' to execute a command.
default: help

# Display help
help:
  @printf "\nRun 'just -n <command>' to print what would be executed...\n\n"
  @just --list --unsorted
  @printf "\n...by running 'just <command>'.\n"
  @printf "This message is printed by 'just help' and just 'just'.\n"

# Print nix flake inputs and outputs
[group('nix')]
io:
  nix flake metadata
  nix flake show

# Update nix flake
[group('nix')]
update:
  nix flake update

# Lint nix files
[group('nix')]
lint:
  nix fmt 

# Check nix flake
[group('nix')]
check:
  nix flake check

# Manually enter dev shell
[group('nix')]
dev:
  nix develop

# Build nix flake
[group('nix')]
build: lint check
  nix build

# Remove build output link (no garbage collection)
[group('nix')]
clean:
  rm -f ./result

# Run nix flake to setup environment
[group('nix')]
run: lint check
  nix run

# Container variants produced by this flake
_containers := "nixpod ghanix codenix jupnix"

container_registry := "ghcr.io/cameronraysmith/"

# Build container image (produces nix2container JSON manifest)
[group('containers')]
container-build variant="nixpod":
  nix build ".#{{variant}}" -L

# Build all container variants
[group('containers')]
container-build-all:
  #!/usr/bin/env bash
  for c in {{_containers}}; do
    echo "Building $c..."
    nix build ".#$c" -L
  done

# Load container image into Docker daemon
[group('containers')]
container-load variant="nixpod":
  docker info > /dev/null 2>&1 || (echo "The docker daemon is not running" && exit 1)
  nix run ".#{{variant}}.copyToDockerDaemon"

# Push multi-arch manifest to registry (requires --impure for env vars)
[group('containers')]
container-push variant="nixpod":
  nix run --impure ".#{{variant}}Manifest" -L

# Push all container manifests
[group('containers')]
container-push-all:
  #!/usr/bin/env bash
  for c in {{_containers}}; do
    echo "Pushing $c manifest..."
    nix run --impure ".#${c}Manifest" -L
  done

# Run a container image locally via Docker
[group('containers')]
container-run variant="nixpod" tag="latest":
  docker info > /dev/null 2>&1 || (echo "The docker daemon is not running" && exit 1)
  docker run -it --rm {{container_registry}}{{variant}}:{{tag}}

# Run nixpkgs hello and nix-health
[group('nix')]
checknix:
  nix run nixpkgs#hello # 30s
  nix run github:srid/nix-health # 3m

## CI/CD

# Docker command to run sethvargo/ratchet to pin GitHub Actions workflows version tags to commit hashes
ratchet_base := "docker run -it --rm -v \"${PWD}:${PWD}\" -w \"${PWD}\" ghcr.io/sethvargo/ratchet:0.9.2"

# List of GitHub Actions workflows
gha_workflows := ".github/actions/build-nix-image/action.yml .github/actions/setup-nix/action.yml .github/actions/tag-build-push-container/action.yml .github/workflows/cid.yaml .github/workflows/containers.yaml .github/workflows/labeler.yml .github/workflows/pr-check.yaml .github/workflows/pr-merge.yaml .github/workflows/update-flake-lock.yml"

# Pin all workflow versions to hash values (requires Docker)
[group('CI/CD')]
ratchet-pin:
  @for workflow in {{gha_workflows}}; do \
    eval "{{ratchet_base}} pin $workflow"; \
  done

# Unpin hashed workflow versions to semantic values (requires Docker)
[group('CI/CD')]
ratchet-unpin:
  @for workflow in {{gha_workflows}}; do \
    eval "{{ratchet_base}} unpin $workflow"; \
  done

# Update GitHub Actions workflows to the latest version (requires Docker)
[group('CI/CD')]
ratchet-update:
  @for workflow in {{gha_workflows}}; do \
    eval "{{ratchet_base}} update $workflow"; \
  done

# List available workflows and associated jobs
[group('CI/CD')]
list-workflows:
  @act -l

# Trigger CI workflow
[group('CI/CD')]
gh-ci-run branch=`git branch --show-current`:
  gh workflow run cid.yaml --ref "{{branch}}"

# Show recent CI workflow runs
[group('CI/CD')]
gh-workflow-status workflow="cid.yaml" branch=`git branch --show-current` limit="5":
  gh run list --workflow "{{workflow}}" --branch "{{branch}}" --limit "{{limit}}"

# Watch a CI run (uses latest if no run_id)
[group('CI/CD')]
gh-watch run_id="":
  #!/usr/bin/env bash
  if [ -z "{{run_id}}" ]; then
    RUN_ID=$(gh run list --workflow cid.yaml --limit 1 --json databaseId --jq '.[0].databaseId')
  else
    RUN_ID="{{run_id}}"
  fi
  gh run watch "$RUN_ID" --exit-status

# View CI run logs
[group('CI/CD')]
gh-logs run_id="" job="":
  #!/usr/bin/env bash
  if [ -z "{{run_id}}" ]; then
    RUN_ID=$(gh run list --workflow cid.yaml --limit 1 --json databaseId --jq '.[0].databaseId')
  else
    RUN_ID="{{run_id}}"
  fi
  if [ -z "{{job}}" ]; then
    gh run view "$RUN_ID" --log
  else
    gh run view "$RUN_ID" --log --job "{{job}}"
  fi

# Re-run failed CI jobs
[group('CI/CD')]
gh-rerun run_id="" failed_only="true":
  #!/usr/bin/env bash
  if [ -z "{{run_id}}" ]; then
    RUN_ID=$(gh run list --workflow cid.yaml --limit 1 --json databaseId --jq '.[0].databaseId')
  else
    RUN_ID="{{run_id}}"
  fi
  if [ "{{failed_only}}" = "true" ]; then
    gh run rerun "$RUN_ID" --failed
  else
    gh run rerun "$RUN_ID"
  fi

# Cancel a running CI workflow
[group('CI/CD')]
gh-cancel run_id="":
  #!/usr/bin/env bash
  if [ -z "{{run_id}}" ]; then
    RUN_ID=$(gh run list --workflow cid.yaml --limit 1 --json databaseId --jq '.[0].databaseId')
  else
    RUN_ID="{{run_id}}"
  fi
  gh run cancel "$RUN_ID"

# Show existing secrets using sops
[group('secrets')]
show-secrets:
  @echo "=== Shared secrets (vars/shared.yaml) ==="
  @sops -d vars/shared.yaml
  @echo

# Edit shared secrets file
[group('secrets')]
edit-secrets:
  @sops vars/shared.yaml

# Create a new sops encrypted file
[group('secrets')]
new-secret file:
  @sops {{ file }}

# Export unique secrets to dotenv format using sops
[group('secrets')]
export-secrets:
  @echo "# Exported from sops secrets" > .secrets.env
  @sops -d vars/shared.yaml | grep -E '^[A-Z_]+:' | sed 's/: /=/' >> .secrets.env
  @sort -u .secrets.env -o .secrets.env

# Run command with all shared secrets as environment variables
[group('secrets')]
run-with-secrets +command:
  @sops exec-env vars/shared.yaml '{{ command }}'

# Check secrets are available in sops environment
[group('secrets')]
check-secrets:
  @printf "Check sops environment for secrets\n\n"
  @sops exec-env vars/shared.yaml 'env | grep -E "GITHUB|CACHIX|CLOUDFLARE|BITWARDEN" | sed "s/=.*$/=***REDACTED***/"'

# Show specific secret value from shared secrets
[group('secrets')]
get-secret key:
  @sops -d vars/shared.yaml | grep "^{{ key }}:" | cut -d' ' -f2-

# Validate all sops encrypted files can be decrypted
[group('secrets')]
validate-secrets:
  @echo "Validating sops encrypted files..."
  @for file in $(find vars \( -name "*.yaml" -o -name "*.json" \)); do \
    echo "Testing: $file"; \
    sops -d "$file" > /dev/null && echo "  Valid" || echo "  Failed"; \
  done

# Initialize sops age key for new developers
[group('secrets')]
sops-init:
  @echo "Checking sops configuration..."
  @if [ ! -f ~/.config/sops/age/keys.txt ]; then \
    echo "Generating age key..."; \
    mkdir -p ~/.config/sops/age; \
    age-keygen -o ~/.config/sops/age/keys.txt; \
    echo ""; \
    echo "Age key generated. Add this public key to .sops.yaml:"; \
    grep "public key:" ~/.config/sops/age/keys.txt; \
  else \
    echo "Age key already exists"; \
    grep "public key:" ~/.config/sops/age/keys.txt; \
  fi

# Add or update a secret non-interactively
[group('secrets')]
set-secret secret_name secret_value:
  @sops set vars/shared.yaml '["{{ secret_name }}"]' '"{{ secret_value }}"'
  @echo "{{ secret_name }} has been set/updated"

# Rotate a specific secret interactively
[group('secrets')]
rotate-secret secret_name:
  @echo "Rotating {{ secret_name }}..."
  @echo "Enter new value for {{ secret_name }}:"
  @read -s NEW_VALUE && \
    sops set vars/shared.yaml '["{{ secret_name }}"]' "\"$NEW_VALUE\"" && \
    echo "{{ secret_name }} rotated successfully"

# Update keys for existing secrets files after adding new recipients
[group('secrets')]
updatekeys:
  @for file in $(find vars \( -name "*.yaml" -o -name "*.json" \)); do \
    echo "Updating keys for: $file"; \
    sops updatekeys -y "$file"; \
  done
  @echo "Keys updated for all secrets files"

# Update github vars for repo from sops environment
[group('CI/CD')]
ghvars repo="cameronraysmith/nixpod":
  @echo "vars before updates:"
  @echo
  PAGER=cat gh variable list --repo={{ repo }}
  @echo
  sops exec-env vars/shared.yaml '\
  gh variable set CACHIX_CACHE_NAME --repo={{ repo }} --body="$CACHIX_CACHE_NAME" && \
  gh variable set FAST_FORWARD_ACTOR --repo={{ repo }} --body="$FAST_FORWARD_ACTOR"'
  @echo
  @echo "vars after updates (wait 3 seconds for github to update):"
  sleep 3
  @echo
  PAGER=cat gh variable list --repo={{ repo }}

# Update github secrets for repo from sops environment
[group('CI/CD')]
ghsecrets repo="cameronraysmith/nixpod":
  @echo "secrets before updates:"
  @echo
  PAGER=cat gh secret list --repo={{ repo }}
  @echo
  sops exec-env vars/shared.yaml '\
  gh secret set CACHIX_AUTH_TOKEN --repo={{ repo }} --body="$CACHIX_AUTH_TOKEN" && \
  gh secret set CLOUDFLARE_ACCOUNT_ID --repo={{ repo }} --body="$CLOUDFLARE_ACCOUNT_ID" && \
  gh secret set CLOUDFLARE_API_TOKEN --repo={{ repo }} --body="$CLOUDFLARE_API_TOKEN" && \
  gh secret set FAST_FORWARD_PAT --repo={{ repo }} --body="$FAST_FORWARD_PAT" && \
  gh secret set FLAKE_UPDATER_APP_ID --repo={{ repo }} --body="$FLAKE_UPDATER_APP_ID" && \
  gh secret set FLAKE_UPDATER_PRIVATE_KEY --repo={{ repo }} --body="$FLAKE_UPDATER_PRIVATE_KEY"'
  @echo
  @echo "secrets after updates (wait 3 seconds for github to update):"
  sleep 3
  @echo
  PAGER=cat gh secret list --repo={{ repo }}
