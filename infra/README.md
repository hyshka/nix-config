# Incus workloads

One directory per workload. Terranix renders these modules into OpenTofu JSON,
and OpenTofu keeps the Incus image and instance in sync through the Incus
provider.

## A workload

`infra/<name>/default.nix` sets `nixosImages.<name>`; `infra/config.nix`
generates its `incus_image` and `incus_instance`. Anything the generator does
not cover (storage volumes, extra devices, OCI images) is a plain `resource`
block in the same file and merges with the generated config.

| Field | Values |
| --- | --- |
| `kind` | `container` (default) or `virtual-machine` |
| `remote` | `tiny1` (default) or `starship` |
| `project` | `lab-default` (default) or `lab-gpu` |
| `sourceFile` | skip the NixOS image, use the given image |

Containers build `system.build.squashfs`; VMs build
`system.build.repartImage` (qcow2) plus a metadata tarball. Those store paths
reach OpenTofu as `var.image_files`, never as literals in the config.

## State

- App state: `incus_storage_volume` on the `default` pool, mounted at
  `/persist` or the app's data path. Set `security.shifted = "true"` and
  `lifecycle.prevent_destroy = true`.
- Shared media: host bind from `/mnt/storage`, because several workloads read
  the same tree. Bulk media stays on the bind for now; moving it into a volume
  is an open option, not a settled decision.

Platform resources (networks, pools, profiles, restricted-project settings)
belong to the host's `virtualisation.incus.preseed`, not to OpenTofu.

## Commands

| App | Does |
| --- | --- |
| `plan` | preview changes |
| `apply` | apply; CI runs this on merge to `main` |
| `destroy` | remove instances and images |
| `validate` | `tofu validate`; no credentials, no image build |
| `import` | `tofu import` one resource |
| `image-paths` | print image store paths for the attic push |
