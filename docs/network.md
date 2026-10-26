# Network

Facts live in the files named below; this page is the map.

## Hosts

| Host | Role | Runs |
| --- | --- | --- |
| `starship` | desktop, GPU | `ai`, `openchamber` |
| `tiny1` | server, storage | every other workload |
| `ashyn` | laptop | — |
| `rpi4` | Raspberry Pi | — |

All NixOS hosts join the tailnet as their hostname. The Incus remotes use
`<host>.tail7dfc7.ts.net:8443` (`infra/config.nix`).

## Incus

| Thing | Value | Owner |
| --- | --- | --- |
| Remotes | `starship`, `tiny1`, `images` (public), `oci-github` (public) | `infra/config.nix` |
| Bridge on `tiny1` | `incusbr0` `10.223.27.1/24` | `hosts/nixos/tiny1/services/incus.nix` |
| Bridge on `starship` | `incusbr0` `10.166.156.1/24` | `hosts/nixos/starship/incus.nix` |
| Pool `default` | `dir`, `/var/lib/incus/storage-pools/default`, SSD | host preseed |
| Pool `storage` | `dir`, `/mnt/storage/incus`, HDD | host preseed |
| Projects | `lab-default`, `lab-gpu` (device passthrough only) | host preseed |

Workloads get DHCP addresses and are addressed as `<name>.incus`, which the
bridge's dnsmasq resolves. A container uses that resolver by default; a host
that dials `*.incus` needs the bridge routed explicitly (`tiny1` does, for
Prometheus).

Inbound ports are the `proxy` devices in each workload's `infra/<name>/default.nix`.
`caddy` owns `tcp:80,443` and terminates `*.home.hyshka.com`; other workloads
publish their own ports (`ai` 8080, `openchamber` 8888, `samba` 139/445, ...).
