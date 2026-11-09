# OCI workload migration

Move workloads that need no NixOS system configuration to OCI application
containers. An OCI instance pulls an upstream image and gets no init, no
sops-nix, no `nix`, and no kernel or hardware ownership. Only move a workload
when all of these hold:

- it runs as one upstream image
- configuration is env vars or a file the app owns
- state fits in one volume
- it owns no network interface, sysctl, or device driver
- its secrets can be delivered as a file or env var

The payoff is fewer `nixosSystem` evals, squashfs builds, and attic pushes per
apply. Updates become image tag bumps via Renovate.

`infra/byparr/default.nix` is the working example: no `nixosImages` entry, a
hand-written `incus_instance` with `image = "oci-github:..."`.

## Shared prerequisites

- [ ] Add `kind = "oci"` to `infra/config.nix`. Today it generates an
  `incus_image` and a `nixosImages` build for every entry, so an OCI
  workload has to bypass the generator like `byparr` does. The new branch
  should emit the instance, optional storage volume, and no image resource.
  It must not add the `nixos-container` profile: OCI instances want the
  project `default` profile only (eth0 plus root disk).
- [ ] Settle secret delivery. See "Secrets" below. Every item in this file is
  blocked on it.
- [ ] Keep the `<name>.incus` DNS name per workload. Caddy upstreams in
  `infra/caddy/configuration.nix` then keep working unchanged.
- [ ] Pin image tags explicitly and let Renovate bump them. No `latest`.

## A. Lift out of NixOS first

These already run an OCI image inside a NixOS container. The NixOS image only
adds podman, so removing it is mechanical.

- [ ] **silverbullet** (`infra/silverbullet/`)
  - [ ] Drop `nixosImages.silverbullet`.
  - [ ] Instance uses the `silverbulletmd/silverbullet` image already pinned in
    the config, with `silverbullet_data` mounted at `/space`.
  - [ ] Port the sops env file to the agreed secret channel.
  - [ ] Delete `networking.firewall` and the `virtualisation.oci-containers`
    block; both become unnecessary.
- [ ] **bindery** (currently nested in `infra/media-arr/`)
  - [ ] Move to `infra/bindery/`, image `ghcr.io/vavallee/bindery`.
  - [ ] Volume for `/config`, bind `/mnt/storage/mediacenter` at `/data`.
  - [ ] Set the service uid to `999` and the shared gid to `13000` through a
    disk device plus `raw.idmap`. `user = "999:13000"` and
    `--umask=0002` are podman options with no Incus equivalent; verify the
    image honours a umask env var, otherwise files land group-unreadable.
  - [ ] `BINDERY_DOWNLOAD_ALLOW_LOOPBACK` and the `localhost` Prowlarr URL
    become `prowlarr.incus`. Host networking is gone.
  - [ ] Remove the `podman-bindery` unit, the `bindery` user, the tmpfiles rule,
    and the `/var/lib/bindery` persistence entry from `media-arr`.
- [ ] **decluttarr** (currently nested in `infra/media-arr/`)
  - [ ] Move to `infra/decluttarr/`, image
    `ghcr.io/manimatter/decluttarr`.
  - [ ] Volume for `/app/config`; copy `decluttarr.yaml` through the volume
    `file` block, which uploads only at volume create. Do not rely on it for
    later config edits.
  - [ ] Point the Radarr/Sonarr URLs in `decluttarr.yaml` at `media-arr.incus`
    instead of `localhost`.
  - [ ] Port the sops env file to the agreed secret channel.
  - [ ] Remove the `decluttarr-config` oneshot and the `podman-decluttarr` unit
    from `media-arr`.

## B. Worth moving, needs one decision each

- [ ] **immich-kiosk** (`infra/immich-kiosk/`)
  - [ ] Replace the NixOS module with the upstream image.
  - [ ] Convert the module settings to the app's config file or env vars; the
    only system-level item today is `networking.firewall`, which no longer
    applies because traffic comes from Caddy.
  - [ ] Secret: one Immich API key. Use a read-only scoped key.
- [ ] **homepage** (`infra/homepage/`)
  - [ ] Upstream image, config as YAML on a volume.
  - [ ] Secrets: `HOMEPAGE_VAR_*` widget keys. The dashboard is reachable on the
    LAN without auth, so these must stay server-side; do not fold them into
    the YAML that ships in git.
  - [ ] Optional simplification: drop the widgets that need keys (Grafana,
    Immich, Jellyfin, the \*arr suite) and keep `siteMonitor` links, which
    makes the workload genuinely secret-free.
- [ ] **ntfy** (`infra/ntfy/`)
  - [ ] Upstream image, `server.yml` on a volume plus the cache volume.
  - [ ] Secrets: auth user file and tokens. The env file today is the whole
    auth database, so this one is only as good as the secret channel.
- [ ] **pinchflat** (`infra/pinchflat/`)
  - [ ] Upstream image, volume for `/config`, bind
    `/mnt/storage/mediacenter/media/youtube` at `/downloads`.
  - [ ] Needs gid `13000` write access plus `umask 0002`. Same idmap friction as
    bindery.
  - [ ] Secret: one env file.

## Not candidates

Keep these as NixOS containers; each fails the criteria for a specific reason.

| Workload | Blocker |
| --- | --- |
| `media-download` | WireGuard netdev, `rp_filter`, resolv kill-switch, routable-wait units |
| `calibre` | `calibre-watch` path unit running `calibredb`, fonts, userdb secret |
| `paperless` | OIDC secret injected in `ExecStart`, exporter, migration runbook, test-skip overlay |
| `forgejo` | `preStart` reconciling the OIDC auth source, dump, mailer secrets |
| `samba` | `smbpasswd` provisioning unit, avahi publishing, uid/gid map |
| `immich` | Multi-service stack: server, ML, postgres, redis |
| `caddy` | Plugin build with a pinned hash, ACME state, env secret |
| `ai` | ROCm device, `rocmOverrideGfx`, `ollama-rocm` build |
| `openchamber` | Needs `nix` and a login shell for agent builds |
| `attic` | Token-signing secret and a cache-format-sensitive version pin |
| `forgejo-build-runner` | Virtual machine for podman nesting |

`jellyfin` also stays: the GPU device works in OCI, but the NixOS image is what
guarantees the VAAPI driver set.

## Secrets

Open problem. Options and their costs are recorded here so the migration can
start once one is picked. Incus has no secret store. Every secret arrives
through one of three channels:

1. Instance config (`environment.*`, cloud-init) — visible to anything holding
   the project certificate, present in instance backups, and in OpenTofu state
   when set through the provider.
2. Files written into the instance or its volume — content stays out of state
   when `source_path` is used, but the file must exist on the apply runner.
3. The app fetches from a secret manager at runtime — still needs a bootstrap
   credential through channel 1 or 2.

Provider notes, verified against `lxc/incus` 1.2.1:

- `incus_instance.file` and `incus_storage_volume.file` accept `source_path` or
  `content`. `content` lands in state verbatim. Use `source_path` only.
- `source_path` stores the path, not the bytes.
- Change detection compares the `source_path` string, not the file contents. If
  the file changes at the same path, nothing re-uploads. Bump the filename
  (content hash suffix) to force it.
- `incus_storage_volume.file` uploads only at volume create, never on update.
- `incus_instance.exec.environment` and `config` are recorded in state.

Candidate approaches, cheapest first:

- [ ] **CI injects the file.** `tofu apply`, then a workflow step decrypts
  `infra/<name>/secrets/` with sops and runs `incus file push` into the
  running instance. No state, no plaintext in git, no per-workload host
  change. Costs one host deploy of `starship` to add the sops age key to the
  `forgejo-runner-tofu` `LoadCredential` list, which is the same mechanism
  the runner already uses for every other credential.
- [ ] **Secret manager in the lab.** Run OpenBao or Infisical as a NixOS
  container (sops still works there) and give each OCI app a machine
  identity. Bootstrap each app token once through the CI push above, then
  rotate. Reduces long-lived secrets but adds a service to run and back up.
- [ ] **Avoid secrets in the workload.** Drop the auth-dependent features
  (homepage widgets, kiosk API key) so the OCI move needs no secret at all.
  Works for `homepage`; not for `ntfy`.
- [ ] **Reject: `environment.*` in instance config.** Simple, but widens secret
  exposure to the state bucket, instance backups, and every project-cert
  holder.
