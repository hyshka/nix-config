# AGENTS.md

Flake-based NixOS + nix-darwin + standalone home-manager config, plus NixOS
services running in Incus LXC containers and VMs. Secrets are managed with
sops-nix.

## Layout

- `hosts/nixos/<host>/` - NixOS host configs (starship, rpi4, tiny1, ashyn)
- `hosts/darwin/bryan-macbook/` - nix-darwin config (`hyshka-D5920DQ4RN`)
- `hosts/common/` - shared host modules and secrets
- `home/hyshka/<host>.nix` - home-manager entrypoints per host
- `home/{cli,desktop,ai,nixvim}/` - reusable home-manager modules
- `home/ai/` - claude-code + opencode config, agents, commands, hooks
- `modules/nixos/`, `modules/home-manager/` - reusable modules, exported as
  `nixosModules` / `homeManagerModules`; register new files in the dir's `default.nix`
- `containers/<name>.nix` - flake-built Incus container configs (`mkContainer`)
- `infra/<name>/` - Terranix-managed Incus containers and VMs
- `overlays/`, `pkgs/` - custom packages and overlays

## Commands

```bash
nix run .#lint         # prek: treefmt + hygiene hooks over all tracked files
nix flake check        # eval the flake and run checks (formatting)

nh os build|test|switch            # current NixOS host
nh darwin switch                   # macOS
nh home switch                     # standalone home-manager
```

`deploy.sh <hosts> [args]` runs `nixos-rebuild --flake .#<host> switch --target-host root@<host>`
for a comma-separated host list.

## Hooks

Git hooks run through `prek` (`prek.toml`), not the `pre-commit` package.
`treefmt.nix` stays the formatting source of truth.

Skip one hook with `PREK_SKIP=<hook-id>` (`PREK_SKIP=treefmt` while `flake.nix`
cannot evaluate). Never `git commit --no-verify`; CI runs the same config.

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

## Infrastructure (`infra/`)

OpenTofu/Terranix-managed Incus workloads, separate from the flake-built
`containers/*.nix`. Apply is driven by CI (merge to `main`), not by hand.

- `infra/config.nix` auto-discovers every `infra/<name>/default.nix`, which sets
  `nixosImages.<name> = { configuration; kind ? "container"; sourceFile ? null; }`.
  `kind = "container"` imports `infra/container.nix`; `kind = "virtual-machine"`
  imports `infra/virtual-machine.nix`.
- The Terranix `resource` option is a magic merge, so per-instance HCL
  (`resource.incus_instance."<name>"`, `resource.incus_storage_volume`, ...)
  goes directly in `infra/<name>/default.nix` and merges with the instance
  `config.nix` generates.
- Every workload lives in the `lab-default` project; `config.nix` sets it on the
  generated `incus_image`/`incus_instance`. Any resource written by hand
  (`incus_storage_volume`, ...) must set `project = "lab-default"` itself.
- Platform is owned by the host, not tofu: networks (`incusbr0`), pools
  (`default`, `storage`), and the `nixos-container` profile come from
  `virtualisation.incus.preseed` in `hosts/nixos/<host>/…/incus.nix`. There are
  no `incus_network`/`incus_profile` resources.
- Images are wired via `resource.incus_image`: containers use the squashfs,
  VMs use `system.build.repartImage` → `nixos.qcow2` plus the
  `system.build.metadata` tarball.
- Those store paths reach tofu as `var.image_files`, not as literals in the
  config. `infra/config.nix` publishes them through terranix `_meta`, `flake.nix`
  renders them into `imageVarsFile`, and `plan`/`apply`/`destroy` pass
  `-var-file`. `validate` passes nothing, so it never evaluates or builds an
  image and stays cheap however many images exist. An image with an explicit
  `sourceFile` skips the variable.
- The apply workflow also publishes those images to the attic cache: `nix run
  .#image-paths` prints the store paths and `attic push home:nix-config --stdin`
  uploads them with their closures. Each image's `system.build.toplevel` goes
  along so locally-built paths (the pinned podman) substitute instead of
  compiling; the cache's `cache.nixos.org-1` upstream filter skips everything
  upstream already serves. `attic-client` is in the runner's `hostPackages`;
  the token is the `attic-token` credential.
- State is the S3 backend (`s3.home.hyshka.com`), credentials from
  `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`, encrypted via `TF_ENCRYPTION`.
- VMs set `config."security.secureboot" = "false"` (unsigned UKI) and persist on
  an Incus filesystem volume mounted at `/persist`, shared over virtiofs. Do not
  use a block volume, ext4, or an in-guest `mkfs` for `/persist`.
- Disposable scratch for `forgejo-build-runner` (podman graphroot, the Renovate
  cache, the container `/nix` store) lives on the VM root disk under
  `/var/lib/forgejo-cache`. tiny1's pools are `dir`, which cannot host
  `content_type = "block"`, and the root disk is a real block device, so it
  avoids the virtiofs small-file penalty. `/persist` stays virtiofs and
  backup-worthy.
- Flake apps: `nix run '.#plan|apply|destroy|validate'` (`validate` needs no
  credentials or state). Local runs authenticate with the CI client cert via
  `$INCUS_CONF`.

### VM secrets

A VM has no host bind-mount to inject the sops age key the way containers do.
Derive the age identity from the VM's SSH host key, persisted at
`/persist/etc/ssh/ssh_host_ed25519_key` (`sops.age.sshKeyPaths` in
`infra/virtual-machine.nix`). Bootstrap once with

```bash
incus exec <name> -- ssh-keygen -t ed25519 -N "" -f /persist/etc/ssh/ssh_host_ed25519_key
incus exec <name> -- cat /persist/etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age
```

then add that recipient to `.sops.yaml` and re-encrypt. Never keep a plaintext
age key on the local filesystem, and do not ship key material via cloud-init.

See the `infra-vm-migration` skill for the full container → VM recipe.

## House style

- No explanatory comments in `.nix` files; the code and `git log` carry intent.
  Keep only short bootstrap/runbook steps that live nowhere else.
- New `.sops.yaml` creation rules use the age recipient only — no `pgp`.

## Secrets

- sops-nix with age; rules live in `.sops.yaml` (per-host and per-container).
- Host age key: `nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'`.
- Rotate recipients: `sops --config ./.sops.yaml updatekeys <file>`.
- Never commit plaintext secrets.

## External docs

Use the Context7 MCP for upstream library, module, provider, and CLI schema. The
`context7-libraries` skill maps topics to the library IDs and query patterns to
use.

## Key inputs

`nixpkgs` (nixos-unstable); `home-manager`,
`nix-darwin` (lnl7), `sops-nix`, `nixvim`, `catppuccin`, `disko`, `lanzaboote`,
`impermanence`, `plasma-manager`, `nixGL`, `nixos-hardware`, `treefmt-nix`,
`llm-agents`, `opencode-flake`, `openchamber-nix`, `zimfw`, `nur`.

## CI

`.forgejo/workflows/`: `renovate.yaml` (self-hosted Renovate, rules in
`renovate.json`, token in the `RENOVATE_TOKEN` secret), `lint.yaml`
(`nix run .#lint`), `flake-checker.yaml`, and `tofu-apply.yml` /
`tofu-drift.yml` (both on the `nixos:host` runner, trusted, main-only) plus
`tofu-validate.yml` (PR, no credentials). Forgejo ignores `.github/workflows`
once `.forgejo/workflows` exists.
