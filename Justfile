# just is a command runner, Justfile is very similar to Makefile, but simpler.

# Use nushell for shell commands
# To usage this justfile, you need to enter a shell with just & nushell installed:
#
#   nix shell nixpkgs#just nixpkgs#nushell
set shell := ["nu", "-c"]

############################################################################
#
#  Common commands(suitable for all machines)
#
############################################################################

# List all the just commands
default:
    @just --list

# Update all the flake inputs
[group('nix')]
up:
  nix flake update

# Update specific input
# Usage: just upp nixpkgs
[group('nix')]
upp input:
  nix flake update {{input}}

# Open a nix shell with the flake
[group('nix')]
repl:
  nix repl -f flake:nixpkgs

############################################################################
#
#  Build Commands
#
############################################################################

# Build a bootable SD card image for Raspberry Pi
[group('build')]
build-pi:
  nix --experimental-features 'nix-command flakes' build './boot/#nixosConfigurations.pi.config.system.build.sdImage'

# Build a bootable raw-efi image for Linux servers
[group('build')]
build-linux:
  nix --experimental-features 'nix-command flakes' build './boot/#diskImage'

[group('deploy')]
colmena *ARGS:
    nix run .#colmena -- --impure {{ARGS}}

[group('deploy')]
nodes:
    just colmena eval -f flake.nix -E "'{ nodes, ... }: builtins.attrNames nodes'" | jq

[group('deploy')]
dry-run TARGET:
    just colmena apply dry-activate --on {{TARGET}}
