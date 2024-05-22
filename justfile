# Default command when 'just' is run without arguments
# Run 'just <command>' to execute a command.
default: help

# Display help
help:
  @printf "\nRun 'just -n <command>' to print what would be executed...\n\n"
  @just --list --unsorted
  @echo "\n...by running 'just <command>'.\n"
  @echo "This message is printed by 'just help' and just 'just'.\n"

# Print nix flake inputs and outputs
io:
  nix flake metadata
  nix flake show

# Update nix flake
update:
  nix flake update

# Lint nix files
lint:
  nix fmt 

# Check nix flake
check:
  nix flake check

# Manually enter dev shell
dev:
  nix develop

# Build nix flake
build: lint check
  nix build

# Remove build output link (no garbage collection)
clean:
  rm -f ./result

# Run nix flake to setup environment
run: lint check
  nix run

# Compile nix flake to OCI json format
oci:
  nix build .#container

# Build and copy OCI format container image to docker daemon
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
  --source git:https://github.com/cameronraysmith/nixpod-home \
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
checknix:
  nix run nixpkgs#hello # 30s
  nix run github:srid/nix-health # 3m

# Docker command to run sethvargo/ratchet to pin GitHub Actions workflows version tags to commit hashes
ratchet_base := "docker run -it --rm -v \"${PWD}:${PWD}\" -w \"${PWD}\" ghcr.io/sethvargo/ratchet:0.9.2"

# List of GitHub Actions workflows
gha_workflows := ".github/actions/tag-build-push-container/action.yml .github/workflows/ci.yaml .github/workflows/cd.yml .github/workflows/update-flake-lock.yml .github/workflows/labeler.yml .github/workflows/release-drafter.yaml"

# Pin all workflow versions to hash values (requires Docker)
ratchet-pin:
  @for workflow in {{gha_workflows}}; do \
    eval "{{ratchet_base}} pin $workflow"; \
  done

# Unpin hashed workflow versions to semantic values (requires Docker)
ratchet-unpin:
  @for workflow in {{gha_workflows}}; do \
    eval "{{ratchet_base}} unpin $workflow"; \
  done

# Update GitHub Actions workflows to the latest version (requires Docker)
ratchet-update:
  @for workflow in {{gha_workflows}}; do \
    eval "{{ratchet_base}} update $workflow"; \
  done
