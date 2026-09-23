# AGENTS.md

Flake-based NixOS + nix-darwin + standalone home-manager config, plus NixOS
services running in Incus LXC containers. Secrets are managed with sops-nix.

## Layout

- `hosts/nixos/<host>/` - NixOS host configs (starship, rpi4, tiny1, ashyn)
- `hosts/darwin/bryan-macbook/` - nix-darwin config (`hyshka-D5920DQ4RN`)
- `hosts/common/` - shared host modules and secrets
- `home/hyshka/<host>.nix` - home-manager entrypoints per host
- `home/{cli,desktop,ai,nixvim}/` - reusable home-manager modules
- `home/ai/` - claude-code + opencode config, agents, commands, hooks
- `modules/nixos/`, `modules/home-manager/` - reusable modules, exported as
  `nixosModules` / `homeManagerModules`; register new files in the dir's `default.nix`
- `containers/<name>.nix` - Incus container configs
- `overlays/`, `pkgs/` - custom packages and overlays

## Commands

```bash
nix fmt                # treefmt: nixfmt, deadnix, shellcheck, shfmt, yamlfmt
nix flake check        # eval the flake and run checks (formatting)

nh os build|test|switch            # current NixOS host
nh darwin switch                   # macOS
nh home switch                     # standalone home-manager
```

`deploy.sh <hosts> [args]` runs `nixos-rebuild --flake .#<host> switch --target-host root@<host>`
for a comma-separated host list.

## Containers

`incus-manager.sh` defaults to the `tiny1` remote (`--remote` to override).

```bash
./incus-manager.sh bootstrap <name> --nesting   # requires containers/<name>.nix first; then update nix-config
./incus-manager.sh build <name>                 # build + import image (--no-import to skip import)
./incus-manager.sh rebuild <name>               # recreate container from image
./incus-manager.sh restart <name>
./incus-manager.sh deploy <name>                # build + import, rebuild, restart
./incus-manager.sh set-ip|add-persist-disk|add-storage|get-age-key <name>
```

Build/rebuild/restart/deploy accept a comma-separated list. Adding a container:
create `containers/<name>.nix`, `bootstrap` it, add its age key to `.sops.yaml`,
then `deploy`. The flake auto-discovers every `containers/*.nix` (except `default.nix`).

## How the flake is wired

- `mkHome { system, hostname, username ? "hyshka" }` builds `homeConfigurations`
  from `home/<user>/<host>.nix`.
- `mkContainer` builds a `nixosSystem` for each discovered container.
- NixOS/darwin configs use `specialArgs = { inherit inputs outputs; }`.
- Adding a host: create `hosts/<platform>/<host>/`, register it in
  `nixosConfigurations` / `darwinConfigurations`, add `home/hyshka/<host>.nix`
  and a matching `mkHome` entry.

## Secrets

- sops-nix with age; rules live in `.sops.yaml` (per-host and per-container).
- Host age key: `nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'`.
- Rotate recipients: `sops --config ./.sops.yaml updatekeys <file>`.
- Never commit plaintext secrets.

## Key inputs

`nixpkgs` (nixos-unstable), plus pinned `nixpkgs-incus-6-18`; `home-manager`,
`nix-darwin` (lnl7), `sops-nix`, `nixvim`, `catppuccin`, `disko`, `lanzaboote`,
`impermanence`, `plasma-manager`, `nixGL`, `nixos-hardware`, `treefmt-nix`,
`llm-agents`, `opencode-flake`, `openchamber-nix`, `zimfw`, `nur`.

## CI

`.github/workflows/`: `lint.yaml` (nix fmt + `git diff --exit-code`),
`flake-checker.yaml`, `lock-updater.yaml`, `llm-agents-updater.yaml`.
