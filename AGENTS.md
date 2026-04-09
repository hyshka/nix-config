# AGENTS.md

This file provides guidance to agents working with code in this NixOS/nix-darwin configuration repository.

## Overview

A declarative NixOS/macOS configuration repository using Nix Flakes. Manages NixOS hosts, nix-darwin macOS, Incus containers, and home-manager user environments with sops-nix for secrets.

## Key Directories

- `hosts/nixos/<hostname>/` - NixOS host configurations
- `hosts/darwin/<hostname>/` - macOS host configurations
- `home/<username>/` - Home-manager user configs
- `containers/` - Incus LXC container configs
- `modules/nixos/` - Reusable NixOS modules (auto-imported)
- `modules/home-manager/` - Reusable home-manager modules

---

## Build/Lint/Testing Commands

### Formatting & Linting

```bash
# Format all files (Nix, Shell)
nix fmt

# Validate flake (no building)
nix flake check

# Check individual Nix file
nix-instantiate --parse <file.nix>
```

### Building Configurations

```bash
# NixOS: build, test, or switch (uses hostname)
nh os build
nh os test
nh os switch

# macOS
nh darwin switch

# Home-manager (separate from system)
nh home switch

# Specific host (if not current machine)
nh os switch --hostname tiny1
nh home switch --hostname starship
```

### Container Management

```bash
./incus-manager.sh deploy <container>
./incus-manager.sh build <container>
./incus-manager.sh import <container>
```

### Manual Testing

Testing is manual in this repository:

1. Build with `nh os build` or `nh os test`
2. For containers: `./incus-manager.sh build <container>`
3. Verify no Nix evaluation errors
4. Switch and verify system boots correctly

---

## NixOS / Nix best practices

- Pin with `fetchFromGitHub` rev + sha256.
- `nativeBuildInputs` for build-time tools, `buildInputs` for runtime.
- Test derivations with `nix-build` before integrating.

## Code Style Guidelines

### Formatting

- Run `nix fmt` before committing (enforces nixfmt)
- 2-space indentation in attribute sets
- 4-space indentation for multi-line lists/attrsets

### Import Patterns

```nix
# Module imports (at top of file)
{ inputs, lib, pkgs, config, outputs, ... }:

{
  imports = [
    ./shared-module.nix
  ];

  # Use builtins.attrValues for dynamic imports
  imports = builtins.attrValues outputs.homeManagerModules;
}
```

### Naming Conventions

- Files: `kebab-case.nix`
- Variables: `camelCase` or `snake_case` (prefer camelCase)
- Functions: `camelCase`
- Options: `kebab-case`
- Attribute sets: `camelCase` keys

### Function Parameters

```nix
# Unused args use _
{ pkgs, config, ... }:

# Or explicitly ignore
{ pkgs, config, lib, outputs, ... }:
let
  inherit (outputs) overlays;
in
```

### Prefer `inherit`

```nix
# Good
inherit (outputs) nixosModules homeManagerModules;

# Avoid repeating
home = {
  inherit username homeDirectory;
  stateVersion = "23.11";
};
```

### Let Bindings

Use `let` for clarity and to avoid repetition:

```nix
let
  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  # use isLinux, isDarwin
}
```

### Error Handling

- Nix is lazy; use `lib.mkIf` for conditional config
- Use `lib.mkDefault` for sensible defaults
- Use `lib.mkForce` to override module defaults
- Wrap risky operations: `lib.mkIf config.enableFeature { ... }`

### Types

- Use NixOS option types: `types.str`, `types.bool`, `types.int`
- Use `lib.types` for home-manager options
- Enable strict mode in evaluations where possible

### Secrets

- Never commit unencrypted secrets
- Use sops-nix with age encryption
- Store in `hosts/nixos/<host>/secrets.yaml` or `containers/secrets/`
- Update keys: `sops --config ./.sops.yaml updatekeys <file>`

---

## Common Operations

### Add New Host

1. Create `hosts/<platform>/<hostname>/default.nix`
2. Add to `flake.nix` under `nixosConfigurations` or `darwinConfigurations`
3. Add home config: `home/<username>/<hostname>.nix`
4. Add to `homeConfigurations` in flake.nix

### Add New Module

- NixOS: create in `modules/nixos/` (auto-imported)
- Home-manager: create in `modules/home-manager/`

### Add Container

1. Create `containers/<name>.nix` based on `containers/default.nix`
2. Run `./incus-manager.sh bootstrap <name> --nesting`
3. Add secrets to `.sops.yaml` if needed
4. Deploy: `./incus-manager.sh deploy <name>`

---

## Pre-Commit Checklist

Before committing:

- [ ] `nix fmt` passes
- [ ] `nix flake check` passes
- [ ] `nh os build` succeeds (on target host)
- [ ] No secrets committed (check with `git diff`)
- [ ] Changes follow existing patterns in the codebase

---

## Key Inputs

- `nixpkgs`: nixos-unstable
- `home-manager`: nix-community master
- `nix-darwin`: lnl7 master
- `sops-nix`: mic92
- `nixvim`: nix-community
- `catppuccin`: nix
