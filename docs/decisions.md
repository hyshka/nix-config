# Decisions

One line per settled choice, newest last. Add an entry only when the reason
would otherwise be lost.

- **2025-01:** Use cosmere worlds for baremetal host names.
  https://stormlightarchive.fandom.com/wiki/Cosmere#Worlds
- **2026-10:** Hosts keep platform resources (networks, pools,
  profiles, restricted projects) in `virtualisation.incus.preseed`; OpenTofu
  never manages them.
- **2026-10:** App state lives in `incus_storage_volume` on the `default`
  pool. Shared media stays a host bind from `/mnt/storage`, because snapraid
  already backs it up and several workloads read the same tree.
- **2026-10:** Use restricted Incus projects to split workloads by domain, not
  permissions. Start with `lab-default` and go from there. Try to avoid opening
  permission on `lab-default`.
- **2026-10:** CI applies on merge to `main` with a restricted,
  project-scoped client certificate through `$INCUS_CONF`. No manual apply.
- **2026-10:** Workloads are addressed as `<name>.incus` over DHCP. Avoid
  static addresses.
- **2026-11:** Workload identity comes from the config, not from persisted
  runtime state. Containers and the VM run `perlless` + userborn
  (`users.mutableUsers = false`, `userborn.importLegacyState = false`) and do
  not persist `/var/lib/nixos`. Pin `uid`/`gid` only for a static account whose
  numeric id appears on durable storage: DynamicUser units need no pin
  (systemd owns and re-chowns their state dir), accounts with an explicit
  `uid`/`gid` (including `config.ids.uids.*`) are already stable, a `uid = null`
  account that owns durable data must be pinned, and a `uid = null` account
  that owns nothing can stay floating.
- **2026-11:** Workload state belongs in one Incus volume per state directory.
  Keep an impermanence-backed `/persist` when a workload has several
  directories, rather than multiplying volumes or hand-writing bind mounts.
- **2026-11:** `scadrial` runs the mainline kernel (`pkgs.linuxPackages`), not
  nixos-hardware's vendor `linux-rpi`. The vendor kernel adds camera, audio HAT,
  VideoCore, legacy GPIO, and NFS-root support the control plane does not use,
  and it is not in a binary cache, so every install compiles it. Revisit if a
  Pi peripheral needs the vendor tree.
- **2026-11:** The OpenTofu state backend is a SeaweedFS host service on `tiny1`,
  reached at `http://tiny1.tail7dfc7.ts.net:8333`. Never through an Incus
  workload or `s3.home.hyshka.com`, which the CI root can replace. Backblaze B2
  is not a candidate: it rejects `If-None-Match` on `PutObject`, so
  `use_lockfile` cannot lock. Move the store to `scadrial` only with a USB SSD.
- **2026-11:** Control-plane services (DNS, TLS for `adguard` and `auth`, OIDC)
  live on `scadrial`, outside the CI root. `scadrial` runs no Incus, no
  home-manager, and no workloads.
- **2026-11:** `scadrial` issues per-host certificates with the Cloudflare DNS
  challenge and its own token, instead of a second copy of the wildcard. The
  public zone points only at tailnet addresses, so HTTP-01 is unusable.
- **2026-11:** The router keeps DHCP, with `scadrial` first and a public resolver
  second so browsing survives the control plane being down. Clients that pick the
  second server cannot resolve `*.home.hyshka.com`; accepted.
- **2026-11:** Forgejo stays on `tiny1`, with no `prevent_destroy` on the
  instance: `/var/lib/forgejo` is on the guarded volume, so a replacement is a
  restart, not data loss, and the guard would only fail image bumps.
- **2026-11:** The `hyshka.com` zone stays hand-edited in Cloudflare, outside the
  CI root: an apply that removed a record would take `auth` off the tailnet once
  the TTL expired, and the control plane must not depend on what CI can change.
  Per-host A records override `*.home.hyshka.com`; that override is the cutover,
  not certificate issuance.
- **2026-11:** Flake inputs update through `.forgejo/workflows/flake-inputs.yaml`,
  not Renovate. Renovate's nix manager tracks only commit hashes through the
  `git-refs` datasource: branch-tracked inputs yield no candidates, and digest
  updates carry no old/new version, so it cannot attach compare links.
  `nix flake update` plus the lock diff gives every changed input a
  `compare/<old>...<new>` URL in one weekly PR.
