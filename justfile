# Default command when 'just' is run without arguments
# Run 'just <command>' to execute a command.
default: help

# Display help
help:
    @printf "\nRun 'just -n <command>' to print what would be executed...\n\n"
    @just --list
    @echo "\n...by running 'just <command>'.\n"
    @echo "This message is printed by 'just help' and just 'just'.\n"

# Lint nix files
lint:
   nix fmt 
