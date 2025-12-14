# Agent Guidelines for nix-config

## Build/Lint/Test Commands
- **Format code**: `nix fmt` (uses treefmt with nixfmt, deadnix, shellcheck, shfmt)
- **Build NixOS config**: `nixos-rebuild build --flake .#<hostname>` (hostnames: starship, rpi4, tiny1, ashyn, or container names)
- **Build Darwin config**: `darwin-rebuild build --flake .#hyshka-D5920DQ4RN`
- **Deploy to remote**: `./deploy.sh <hostname>` (SSH deployment script)
- **Deploy to remote container**: `./incus-manager.sh deploy <container>` (Incus deployment script)
- **Check flake**: `nix flake check`
- **Update flake inputs**: `nix flake update`

## Code Style Guidelines
- **Formatter**: nixfmt (2 space indentation, enforced via treefmt.nix)
- **Imports**: Use `{ inputs, outputs, pkgs, lib, config, ... }:` pattern, inherit from inputs where needed
- **Structure**: Function signature with imports, then attribute set with `imports = [ ... ]` first, followed by config options
- **Naming**: Use kebab-case for hostnames/files, camelCase for Nix attributes, descriptive names for options
- **Comments**: Use `#` for single-line comments, add explanatory comments for non-obvious configuration
- **Special Args**: Pass `{ inherit inputs outputs; }` as specialArgs to nixosSystem/darwinSystem
- **Error Handling**: No explicit error handling - let Nix evaluation errors surface naturally
- **Formatting**: Follow .editorconfig (LF line endings, UTF-8, trim trailing whitespace, 2 space indent)
- **Dead Code**: Run deadnix to remove unused code (enabled in treefmt)
- **Shell Scripts**: Must pass shellcheck and shfmt (enabled in treefmt)
