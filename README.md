# nix-config

NixOS hosts, nix-darwin, home-manager, and Incus workloads (LXC, VM, OCI)
provisioned with Terranix and OpenTofu. Secrets are sops-encrypted.

## Layout

| Path | What |
| --- | --- |
| `hosts/` | NixOS and nix-darwin host configs |
| `home/` | home-manager entrypoints and modules |
| `modules/` | reusable NixOS and home-manager modules |
| `infra/` | Incus workloads owned by Terranix/OpenTofu |
| `overlays/`, `pkgs/` | custom packages and overlays |
| `docs/` | network, recovery, decisions |

## Usage

```bash
nh os switch                # current NixOS host
nh darwin switch            # macbook
nh home switch              # standalone home-manager
./deploy.sh starship,tiny1  # remote NixOS switch

nix run '.#plan'            # preview infra changes
nix run '.#apply'           # apply infra (CI does this on main)
nix run '.#validate'        # eval + validate, no credentials
nix run '.#lint'            # treefmt + hygiene hooks
```

## Docs

- [Network](docs/network.md)
- [Recovery](docs/recovery.md)
- [Decisions](docs/decisions.md)
- [Workloads](infra/README.md)
- Agent rules: [AGENTS.md](AGENTS.md)
