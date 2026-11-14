# Recovery

What has to survive disk loss, and where the copies are. Sources:
`hosts/nixos/tiny1/services/restic.nix`, `snapraid.nix`,
`infra/*/default.nix`, `infra/virtual-machine.nix`.

## What matters

| Data | Where | Copy |
| --- | --- | --- |
| Secrets | sops files in git; container age keys staged to `/run/incus-secrets` (tmpfs, rebuilt each boot) | git, plus the user age/PGP key off-machine |
| Host identity | `/etc/ssh/ssh_host_ed25519_key` per host | your backup of the key itself |
| VM identity | `/persist/etc/ssh/ssh_host_ed25519_key` on the VM volume | restic |
| Workload state | `default` pool, `/var/lib/incus/storage-pools/default/custom/` | restic |
| Media and shares | `/mnt/storage` (mergerfs over 4 bay enclosure) | snapraid parity, plus restic for the listed paths |
| Host config | this repo | forgejo |

## Restic

Backblaze B2 bucket `storage-hyshka`. `tiny1` runs at 03:00 with
`--keep-daily 7 --keep-weekly 5 --keep-monthly 12 --keep-yearly 2` and owns
pruning; `scadrial` runs at 03:40 with no prune options. Both use `runCheck`.
Credentials are the sops secrets `restic_password` and `restic_environmentFile`
on each host.

`tiny1` covers `/mnt/storage/{hyshka,tm_share,immich}`, `/var/lib/nixos`,
`/var/lib/private/seaweedfs`, and `/var/lib/incus/storage-pools/default/custom/`.
`scadrial` covers `/etc/ssh`, `/var/lib/caddy`, `/var/lib/pocket-id`, and
`/var/lib/private/AdGuardHome`. Thumbnails, transcodes and `.snapshots` are
excluded.

```bash
restic -r s3:s3.us-west-000.backblazeb2.com/storage-hyshka snapshots
restic -r s3:s3.us-west-000.backblazeb2.com/storage-hyshka restore latest --target /mnt/restore
```

```bash
restic -r s3:s3.us-west-000.backblazeb2.com/storage-hyshka snapshots
restic -r s3:s3.us-west-000.backblazeb2.com/storage-hyshka restore latest --target /mnt/restore
```

## Snapraid

`/mnt/storage` is a mergerfs view over `/mnt/disk1` and `/mnt/disk3`, with
parity on `/mnt/parity2` and content files at `/var/snapraid.content` and per
disk. It protects against a disk failure, not against deletion or a bad write.
`snapraid fix` rebuilds missing data; `snapraid sync` refreshes parity.

## Order

1. Reinstall the host and restore its SSH host key first. Without it the host
   cannot decrypt its own sops files; with only the user key, re-encrypt via
   `sops --config ./.sops.yaml updatekeys <file>`.
2. Add the age recipients back to `.sops.yaml` if a key changed, then
   `nix run '.#apply'` to recreate instances and empty volumes.
3. Stop the instance, restore its volume directory from restic, start it. The
   directory is `custom/<project>_<volume>` under the `default` pool, for
   example `custom/lab-gpu_jellyfin-persist`.
4. Rebuild media from parity, or restore the restic path list above.
5. `nix run '.#plan'` should be empty when the lab matches the repo.

## Known gaps

- Container and VM uids are not pinned yet for `forgejo`, `jellyfin`,
  `openchamber`, `pinchflat`, `qbittorrent`, `sabnzbd`, and `recyclarr`. Until
  they are, a volume that survives an image replacement relies on userborn's
  deterministic allocation.
- `starship` state has no offsite copy; restic runs on `tiny1` and `scadrial`
  only.
- Volumes on the `storage` pool (`/mnt/storage/incus`) rely on snapraid, not
  restic.
- No restore drill is recorded yet, so the steps above are the intended path,
  not a verified one.
