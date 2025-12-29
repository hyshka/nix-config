# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS and macOS configuration repository using Nix Flakes. It manages multiple systems (NixOS hosts, nix-darwin macOS, and Incus containers) with declarative configurations, home-manager for user environments, and sops-nix for secrets management.

## Architecture

### Configuration Structure

The repository follows a modular architecture with reusable components:

- **`hosts/`**: Per-host system configurations organized by platform
  - `hosts/common/`: Shared cross-platform modules (nix, nixpkgs, zsh, fonts, sops)
  - `hosts/nixos/`: NixOS hosts and configurations
    - `hosts/nixos/<hostname>/default.nix`: Main entry point for each NixOS host
    - `hosts/nixos/common/global/`: Configurations applied to all NixOS hosts (imports all `outputs.nixosModules`)
    - `hosts/nixos/common/`: Opt-in NixOS configurations (e.g., plasma, sway, pipewire, wireless)
    - `hosts/nixos/common/users/`: NixOS user account definitions
  - `hosts/darwin/`: nix-darwin (macOS) hosts and configurations
    - `hosts/darwin/<hostname>/default.nix`: Main entry point for each darwin host
    - `hosts/darwin/common/global/`: Configurations applied to all darwin hosts

- **`home/`**: Home-manager user configurations (standalone, deployed separately from system)
  - `home/<username>/<hostname>.nix`: Per-host user configuration
  - `home/<username>/global/`: User-level global settings
  - `home/<username>/features/`: Modular home-manager features (e.g., alacritty, sway, claude)
  - `home/cli/`: CLI tool configurations (bat, git, tmux, zsh, etc.)
  - `home/nixvim/`: Nixvim (Neovim) configuration
  - `home/desktop/`: Desktop-related configurations

- **`modules/`**: Reusable NixOS and home-manager modules
  - `modules/nixos/`: Custom NixOS modules (auto-imported via `outputs.nixosModules`)
  - `modules/home-manager/`: Custom home-manager modules

- **`containers/`**: Incus LXC container configurations
  - Each container has its own `.nix` file (e.g., `paperless.nix`, `immich.nix`)
  - `containers/secrets/`: Container-specific sops secrets
  - See `containers/README.md` for container management details

- **`overlays/`**: Package overlays and modifications
- **`pkgs/`**: Custom package definitions

### Key Inputs

- **nixpkgs**: Tracking unstable channel
- **home-manager**: User environment management
- **nix-darwin**: macOS system management
- **sops-nix**: Secrets management using age encryption
- **plasma-manager**: KDE Plasma declarative configuration
- **nixvim**: Neovim configuration framework
- **catppuccin**: Theming framework
- **lanzaboote**: Secure boot support
- **disko**: Declarative disk partitioning
- **impermanence**: Ephemeral root filesystem support

### Secrets Management

Secrets are managed using sops-nix with age encryption:

- **`.sops.yaml`**: Defines encryption keys and creation rules
- Age keys are derived from SSH host keys: `nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'`
- Secrets stored in:
  - `hosts/nixos/common/secrets.yaml`: Shared NixOS host secrets
  - `hosts/nixos/<hostname>/secrets.yaml`: NixOS host-specific secrets
  - `containers/secrets/<container>.yaml`: Container secrets
- Update keys after changes: `sops --config ./.sops.yaml updatekeys <path-to-secrets.yaml>`

## Common Commands

### Building and Switching Configurations

**NixOS hosts (system only):**
```bash
# Build and switch (requires root)
sudo nixos-rebuild switch --flake .#<hostname>

# Build without switching
nixos-rebuild build --flake .#<hostname>

# Test configuration (temporary, reverts on reboot)
sudo nixos-rebuild test --flake .#<hostname>
```

**macOS (nix-darwin, system only):**
```bash
darwin-rebuild switch --flake .#hyshka-D5920DQ4RN
```

**Home-manager (user environment, deployed separately):**
```bash
# Using home-manager directly
home-manager switch --flake .#hyshka@<hostname>

# Using nh (recommended)
nh home switch . -c hyshka@<hostname>

# Available configurations:
# - hyshka@tiny1, hyshka@starship, hyshka@ashyn (x86_64-linux)
# - hyshka@macbook (aarch64-darwin)
```

**Note:** System and home-manager configurations are decoupled. After `nixos-rebuild switch`, run `nh home switch` separately to update user environment.

### Incus Container Management

Use the `./incus-manager.sh` script for container operations:

**Deployment (common workflow):**
```bash
# Build, import, rebuild, and restart
./incus-manager.sh deploy <container>

# Individual steps
./incus-manager.sh build <container>
./incus-manager.sh import <container>
./incus-manager.sh rebuild <container>
./incus-manager.sh restart <container>
```

**Container creation:**
```bash
./incus-manager.sh create <container>
./incus-manager.sh add-persist-disk <container>
incus start <container>
./incus-manager.sh set-ip <container>
./incus-manager.sh get-age-key <container>  # For sops secrets
```

See `containers/README.md` for detailed container setup workflow.

### Formatting and Linting

```bash
# Format all Nix files
nix fmt

# Format is defined in treefmt.nix and includes:
# - nixfmt: Nix code formatting
# - deadnix: Remove unused Nix code
# - shellcheck: Shell script linting
# - shfmt: Shell script formatting
```

### Development Shell

```bash
# Enter development shell (defined in shell.nix)
nix develop
```

### Package Management

```bash
# Build custom packages
nix build .#<package-name>

# Run custom packages
nix run .#<package-name>

# List available packages
nix flake show
```

### Flake Operations

```bash
# Update all flake inputs
nix flake update

# Update specific input
nix flake lock --update-input <input-name>

# Check flake
nix flake check
```

## Development Workflow

### Adding a New Host

1. Create `hosts/<hostname>/default.nix`
2. Import desired modules from `hosts/common/global/` and `hosts/common/`
3. Add host-specific configuration (hardware, networking, etc.)
4. Generate age key and add to `.sops.yaml`
5. Create `hosts/<hostname>/secrets.yaml` if needed
6. Create `home/<username>/<hostname>.nix` for user configuration
7. Add to `flake.nix` under `nixosConfigurations` or `darwinConfigurations`
8. Add to `flake.nix` under `homeConfigurations` using `mkHome` helper

### Adding a New Module

**NixOS module:**
- Create in `modules/nixos/`
- Will be auto-imported via `outputs.nixosModules`

**Home-manager module:**
- Create in `modules/home-manager/`
- Export in `modules/home-manager/default.nix`

### Adding a New Container

Follow the workflow in `containers/README.md`:
1. Create `containers/<name>.nix` based on `containers/default.nix`
2. Build and import: `./incus-manager.sh import <name>`
3. Create container: `./incus-manager.sh create <name>`
4. Add persist disk and set IP
5. Get age key and add to `.sops.yaml`
6. Create `containers/secrets/<name>.yaml`
7. Deploy: `./incus-manager.sh deploy <name>`

## Project Conventions

### Nix Coding Style

- Use `nixfmt` formatting (enforced by `nix fmt`)
- Prefer `inherit` over repetition
- Use `let` bindings for clarity
- Follow existing patterns in the codebase

### Module Organization

- Global configurations go in `hosts/common/global/`
- Optional features go in `hosts/common/`
- User configurations are per-host in `home/<username>/<hostname>.nix`
- Keep modules focused and composable

### Secrets Handling

- Never commit unencrypted secrets
- Always use sops-nix for sensitive data
- Hash passwords with `mkpasswd` before adding to secrets
- Derive age keys from SSH host keys for consistency

### Container Conventions

- Default remote: `tiny1` (configurable via `INCUS_DEFAULT_REMOTE`)
- Persist path: `/persist/microvms/<container>`
- Use `incus-manager.sh` for all container operations
- Keep container configs minimal; use NixOS modules for shared logic

## Testing Changes

Before committing:

1. Run `nix fmt` to format code
2. Run `nix flake check` to validate the flake
3. Test build locally: `nixos-rebuild build --flake .#<hostname>`
4. For containers, test with `./incus-manager.sh build <container>`
5. Verify secrets decrypt correctly after key changes
