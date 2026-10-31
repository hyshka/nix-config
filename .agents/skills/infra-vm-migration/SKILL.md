---
name: Infrastructure VM migration
description: Move an Incus LXC container into a Terranix-managed virtual machine under infra/, or add a new VM there
---

# Migrating a container to a VM under `infra/`

Use when moving an existing Incus LXC container into an `infra/<name>/`
Terranix workload with `kind = "virtual-machine"`, or when adding any new VM
under `infra/`.

Read `infra/config.nix`, `infra/container.nix`, `infra/virtual-machine.nix`, and
a sibling such as `infra/forgejo-build-runner/` before changing anything. Do not re-derive the
nixpkgs module wiring; it is already captured below.

## Steps

1. Create `infra/<name>/configuration.nix` with the container's services, sops
   secrets, and `environment.persistence."/persist"`.

2. Create `infra/<name>/default.nix`:

   ```nix
   {
     nixosImages."<name>" = {
       configuration = ./configuration.nix;
       kind = "virtual-machine";
     };

     resource.incus_instance."<name>" = {
       config."security.secureboot" = "false";
       device = [
         {
           name = "persist";
           type = "disk";
           properties = {
             pool = "default";
             source = "<name>-persist";
             path = "/persist";
           };
         }
       ];
     };

     resource.incus_storage_volume."<name>-persist" = {
       name = "<name>-persist";
       pool = "default";
       project = "lab-default";
     };
   }
   ```

3. Move secrets to `infra/<name>/secrets/`, add a `.sops.yaml` creation rule
   (age recipient only, no `pgp`), and re-encrypt for the VM's host-key
   recipient (see below).

4. Remove the old container definition once the VM is verified.
   `infra/config.nix` auto-discovers `infra/*/default.nix`, so nothing to
   register.

5. `nix fmt`, then evaluate the terranix config to confirm the merge produces a
   single instance resource with `config`, `device`, `image`, `name`, and
   `type = "virtual-machine"`.

## Facts that are easy to get wrong

- **Image paths.** In `infra/config.nix`, `imageArtifact.virtual-machine` is
  `data_path = ${config.system.build.repartImage}/nixos.qcow2` and
  `metadata_path = ${config.system.build.metadata}/tarball/${config.image.baseName}.tar.xz`.
  Use `config.image.baseName`; `config.image.fileName`/`filePath` hit an
  `image.extension` conflict between `lxc-image-metadata.nix` and `repart.nix`.

- **Boot.** The UKI is unsigned, so set
  `config."security.secureboot" = "false"` on the instance, and wait for the
  Incus agent after boot.

- **Persist.** Attach an Incus filesystem volume and mount at `/persist`.
  `incus-virtual-machine.nix` pulls in 9p/virtiofs via `qemu-guest.nix`, so it
  is a plain shared volume from the host pool (tiny1's is btrfs). Do not use a
  block volume, ext4, or an in-guest `mkfs`; leave `content_type` at the
  filesystem default. Keep the pool name consistent with the rest of `infra/`
  (currently `default`).

- **Project.** Workloads live in `lab-default`; `config.nix` sets it on the
  generated image and instance, but a resource you write by hand (the storage
  volume) needs `project = "lab-default"` itself. Profiles are project-scoped,
  so instances select the `nixos-container` profile from `lab-default` (created
  by the host preseed), not from `default`.

- **VM sops age key.** A VM has no host bind-mount to inject the key the way
  containers do. `infra/virtual-machine.nix` derives the age identity from the
  VM's persisted SSH host key at
  `/persist/etc/ssh/ssh_host_ed25519_key` (`sops.age.sshKeyPaths`). Bootstrap
  once, then re-encrypt:

  ```bash
  incus exec <name> -- ssh-keygen -t ed25519 -N "" -f /persist/etc/ssh/ssh_host_ed25519_key
  incus exec <name> -- cat /persist/etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age
  ```

  Add the resulting recipient to `.sops.yaml` and re-encrypt the image's
  secrets. Never keep a plaintext age key on the local filesystem, and do not
  use cloud-init to ship key material.

## Conventions

- No explanatory comments in `.nix` files; keep only short bootstrap/runbook
  steps that live nowhere else.
