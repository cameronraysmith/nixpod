# Default command when 'just' is run without arguments
# Run 'just <command>' to execute a command.
default: help

# Display help
help:
  @printf "\nRun 'just -n <command>' to print what would be executed...\n\n"
  @just --list
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

# Build nix flake
build: lint check
  nix build

# Remove build output link (no garbage collection)
clean:
  rm -f ./result

# Run nix flake to setup environment
run: lint check
  nix run

#----------------------------------------------------------------
# The just recipes below are for testing the flake in a container
#----------------------------------------------------------------

builder := "docker"
container_user := "runner"
container_home := "/home" / container_user
container_work := container_home / "work"

container_command_type := "runflake"
# If you want to test the flake manually check
# $ just -n container_command_type="bash" testcontainer-run
# and then run the container with
# $ just container_command_type="bash" testcontainer-run
# To activate home manager inside the container run: 
#   > rm -f ~/.bashrc ~/.profile && nix run && direnv allow && zsh
container_command := if container_command_type == "runflake" {
    "cd " + container_home + " && rm -f .bashrc .profile .zshrc && cd " + container_work + " && nix run && direnv allow && zsh"
  } else if container_command_type == "bash" {
    "cd " + container_work + ' && echo "export PS1=\"> \"" >> ~/.bashrc && exec bash'
  } else {
    error("container_command_type must be either 'runflake' or 'bash'") 
  }

# Build and load container image for testing the flake in a container
testcontainer-build:
  {{builder}} build -t debnix:latest -f testing/Dockerfile .

# Run the test container image
testcontainer-run mount_path="$(pwd)": testcontainer-build
  {{builder}} run -it --entrypoint "/bin/bash" \
  --rm -v {{mount_path}}:{{container_work}} debnix:latest \
  -c '{{container_command}}'

# Get test image digest
testcontainer-digest:
  {{builder}} run -it --rm \
  --entrypoint skopeo quay.io/skopeo/stable \
  inspect docker://docker.io/debian:stable-slim | \
  jq -r .Digest | tr -d '\n'

# Get test image tarball sha256
testcontainer-sha256:
  {{builder}} pull debian:stable-slim
  {{builder}} save -o debian_stable_slim.tar debian:stable-slim
  nix-hash --type sha256 --base16 debian_stable_slim.tar
  nix-hash --type sha256 --base32 debian_stable_slim.tar
  nix-hash --type sha256 --base64 debian_stable_slim.tar
  rm debian_stable_slim.tar || true

# # Build and Load the Docker Image with nix
# buildnix:
#     @echo "Building the Docker image..."
#     nix build .#dockerImage
#     @echo "Loading the Docker image into Docker daemon..."
#     docker load < result

# # Run the Docker Container built by nix
# runnix: buildnix
#     @echo "Running the Docker container..."
#     docker run -it --rm -v $(pwd):/mnt debnix:latest
