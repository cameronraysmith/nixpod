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

# Compile nix flake to OCI json format
[group('nix')]
oci:
  nix build .#container

# Build and copy OCI format container image to docker daemon
[group('nix')]
nixcontainer:
  docker info > /dev/null 2>&1 || (echo "The docker daemon is not running" && exit 1)
  nix run .#container.copyToDockerDaemon

#----------------------------------------------------------------
# The just recipes below are for testing the flake in a container
#----------------------------------------------------------------

builder := "docker"
container_user := "runner"
container_home := "/home" / container_user
container_work := container_home / "work"
container_registry := "ghcr.io/cameronraysmith/"

container_type := "testing" # or "container"
container_image := if container_type == "testing" {
    "debnix"
  } else if container_type == "container" {
    "nixpod"
  } else {
    error("container_type must be either 'testing' or 'container'") 
  }
container_tag := "latest"

architecture := if arch() == "x86_64" {
    "amd64"
  } else if arch() == "aarch64" {
    "arm64"
  } else {
    error("unsupported architecture must be amd64 or arm64")
  }

opsys := if os() == "macos" {
    "darwin"
  } else if os() == "linux" {
    "linux"
  } else {
    error("unsupported operating system must be darwin or linux")
  }

devpod_release := "latest" # or "v0.3.7" or "v0.4.0-alpha.4"

devpod_binary_url := if devpod_release == "latest" {
  "https://github.com/loft-sh/devpod/releases/latest/download/devpod-" + opsys + "-" + architecture
} else {
  "https://github.com/loft-sh/devpod/releases/download/" + devpod_release + "/devpod-" + opsys + "-" + architecture
}

# Install devpod
[unix]
install-devpod:
  curl -L -o devpod {{devpod_binary_url}} && \
  sudo install -c -m 0755 devpod /usr/local/bin && \
  rm -f devpod
  which devpod
  devpod version

# Print devpod info
devpod:
  devpod version && echo
  devpod context list
  devpod provider list
  devpod list

# Install and use devpod kubernetes provider
provider:
  devpod provider add kubernetes --silent || true \
  && devpod provider use kubernetes

# Run latest container_image in current kube context
pod:
  devpod up \
  --devcontainer-image {{container_registry}}{{container_image}}:{{container_tag}} \
  --provider kubernetes \
  --ide vscode \
  --open-ide \
  --source git:https://github.com/cameronraysmith/nixpod \
  --provider-option DISK_SIZE=100Gi \
  {{container_image}}

# Interactively select devpod to stop
stop: 
  devpod stop

# Interactively select devpod to delete
delete: 
  devpod delete

container_command_type := "sysbash"
# If you want to 
# **test the flake manually**
# check the output of
# $ just -n container_command_type="testingbash" container-run
# and then run the container with
# $ just container_command_type="testingbash" container-run
# To activate home manager inside the container run: 
#   > rm -f ~/.bashrc ~/.profile && nix run && direnv allow && zsh
container_command := if container_command_type == "runflake" {
    "cd " + container_home + " && rm -f .bashrc .profile .zshrc && cd " 
    + container_work + " && nix run && direnv allow && zsh"
  } else if container_command_type == "testingbash" {
    "cd " + container_work + ' && echo "export PS1=\"> \"" >> ~/.bashrc && exec bash'
  } else if container_command_type == "sysbash" {
    "/bin/bash"
  } else if container_command_type == "zsh" {
    "zsh"
  } else {
    error("container_command_type must be one of 
          'runflake', 'testingbash', 'sysbash' or 'zsh'") 
  }

# Pull container image from registry
container-pull:
  {{builder}} pull {{container_registry}}{{container_image}}:{{container_tag}}

# Build and load image for running the flake in a container
container-build: container-pull
  {{builder}} build -t {{container_registry}}{{container_image}}:{{container_tag}} -f containers/Containerfile.{{container_image}} .

# Build the image only if pull fails
container-pull-or-build:
  {{builder}} pull {{container_registry}}{{container_image}}:{{container_tag}} || \
  {{builder}} build -t {{container_registry}}{{container_image}}:{{container_tag}} -f containers/Containerfile.{{container_image}} .

# Run the container image
container-run mount_path="$(pwd)": container-pull-or-build
  {{builder}} run -it \
  --rm -v {{mount_path}}:{{container_work}} {{container_registry}}{{container_image}}:{{container_tag}} \
  -c '{{container_command}}'

# Get base image digest
basecontainer-digest:
  {{builder}} run -it --rm \
  --entrypoint skopeo quay.io/skopeo/stable \
  inspect docker://docker.io/debian:stable-slim | \
  jq -r .Digest | tr -d '\n'

# Get base image tarball sha256
basecontainer-sha256:
  {{builder}} pull debian:stable-slim
  {{builder}} save -o debian_stable_slim.tar debian:stable-slim
  nix-hash --type sha256 --base16 debian_stable_slim.tar
  nix-hash --type sha256 --base32 debian_stable_slim.tar
  nix-hash --type sha256 --base64 debian_stable_slim.tar
  rm debian_stable_slim.tar || true

# Run nixpkgs hello and nix-health
[group('nix')]
checknix:
  nix run nixpkgs#hello # 30s
  nix run github:srid/nix-health # 3m

## CI/CD

# Docker command to run sethvargo/ratchet to pin GitHub Actions workflows version tags to commit hashes
ratchet_base := "docker run -it --rm -v \"${PWD}:${PWD}\" -w \"${PWD}\" ghcr.io/sethvargo/ratchet:0.9.2"

# List of GitHub Actions workflows
gha_workflows := ".github/actions/tag-build-push-container/action.yml .github/workflows/cid.yaml .github/workflows/cd.yml .github/workflows/update-flake-lock.yml .github/workflows/labeler.yml .github/workflows/release-drafter.yaml"

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

# Update github vars for repo from environment variables
[group('CI/CD')]
ghvars repo="cameronraysmith/nixpod":
  @echo "vars before updates:"
  @echo
  PAGER=cat gh variable list --repo={{ repo }}
  @echo
  gh variable set CACHIX_CACHE_NAME --repo={{ repo }} --body="$CACHIX_CACHE_NAME"
  @echo
  @echo vars after updates:
  @echo
  PAGER=cat gh variable list --repo={{ repo }}

# Update github secrets for repo from environment variables
[group('CI/CD')]
ghsecrets repo="cameronraysmith/nixpod":
  @echo "secrets before updates:"
  @echo
  PAGER=cat gh secret list --repo={{ repo }}
  @echo
  eval "$(teller sh)" && \
  gh secret set CACHIX_AUTH_TOKEN --repo={{ repo }} --body="$CACHIX_AUTH_TOKEN" && \
  gh secret set ARTIFACT_REGISTRY_PASSWORD --repo={{ repo }} --body="$ARTIFACT_REGISTRY_PASSWORD"
  @echo
  @echo secrets after updates:
  @echo
  PAGER=cat gh secret list --repo={{ repo }}

# List available workflows and associated jobs.
[group('CI/CD')]
list-workflows:
  @act -l

# Execute flake.yaml workflow.
[group('CI/CD')]
test-flake-workflow:
  @teller run -s -- \
  act workflow_dispatch \
  -W '.github/workflows/cid.yaml' \
  -j nixci \
  -s GITHUB_TOKEN -s CACHIX_AUTH_TOKEN \
  --matrix os:ubuntu-latest

## secrets

# Define the project variable
gcp_project_id := env_var_or_default('GCP_PROJECT_ID', 'development')

# Show existing secrets
[group('secrets')]
show:
  @teller show

# Create a secret with the given name
[group('secrets')]
create-secret name:
  @gcloud secrets create {{name}} --replication-policy="automatic" --project {{gcp_project_id}}

# Populate a single secret with the contents of a dotenv-formatted file
[group('secrets')]
populate-single-secret name path:
  @gcloud secrets versions add {{name}} --data-file={{path}} --project {{gcp_project_id}}

# Populate each line of a dotenv-formatted file as a separate secret
[group('secrets')]
populate-separate-secrets path:
  @while IFS= read -r line; do \
     KEY=$(echo $line | cut -d '=' -f 1); \
     VALUE=$(echo $line | cut -d '=' -f 2); \
     gcloud secrets create $KEY --replication-policy="automatic" --project {{gcp_project_id}} 2>/dev/null; \
     printf "$VALUE" | gcloud secrets versions add $KEY --data-file=- --project {{gcp_project_id}}; \
   done < {{path}}

# Complete process: Create a secret and populate it with the entire contents of a dotenv file
[group('secrets')]
create-and-populate-single-secret name path:
  @just create-secret {{name}}
  @just populate-single-secret {{name}} {{path}}

# Complete process: Create and populate separate secrets for each line in the dotenv file
[group('secrets')]
create-and-populate-separate-secrets path:
  @just populate-separate-secrets {{path}}

# Retrieve the contents of a given secret
[group('secrets')]
get-secret name:
  @gcloud secrets versions access latest --secret={{name}} --project={{gcp_project_id}}

# Create empty dotenv from template
[group('secrets')]
seed-dotenv:
  @cp .template.env .env

# Export unique secrets to dotenv format
[group('secrets')]
export:
  @teller export env | sort | uniq | grep -v '^$' > .secrets.env

# Check secrets are available in teller shell.
[group('secrets')]
check-secrets:
  @printf "Check teller environment for secrets\n\n"
  @teller run -s -- env | grep -E 'GITHUB|CACHIX' | teller redact

# Save KUBECONFIG to file
[group('secrets')]
get-kubeconfig:
  @teller run -s -- printenv KUBECONFIG > kubeconfig.yaml
