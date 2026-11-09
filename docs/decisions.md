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
