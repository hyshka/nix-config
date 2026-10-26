# Decisions

One line per settled choice, newest last. Add an entry only when the reason
would otherwise be lost.

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
