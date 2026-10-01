# Provision and deploy NixOS LXC containers to Incus

This repo demonstrates using a single command (`nix run .#apply`) to build a NixOS LXC container image as well as provision an instance of the image on a local Incus server.

The pipeline works like this:

- NixOS builds the container image
- [terranix](https://terranix.org/) turns that build into an OpenTofu config
- [OpenTofu](https://opentofu.org/) keeps the [Incus](https://linuxcontainers.org/incus/) image and instance in sync through the [Incus Terraform provider](https://github.com/lxc/terraform-provider-incus)

This works because when the terranix configuration is evaluated by Nix, the metadata and squashfg build targets for the container get evaluated in turn. Any change in the container's closure produces new store paths, so OpenTofu picks up the changed image and rebuilds the instance.

## Prerequisites

- Nix with flakes
- A working `incus` client and your user configured as an `incus-admin`

## Demo

```
# preview changes
nix run .#plan

# upload image, create/update the instance
nix run .#apply

# run a command on the instance
incus exec hello hello

# make a change to hello-container.nix (e.g. add a package)
nix run .#apply

# verify the instance changed
incus exec hello fortune

# remove the instance and the image
nix run .#destroy
```

## Files

| File | Role |
| --- | --- |
| `hello-container.nix` | Minimal NixOS LXC container |
| `config.nix` | Terranix module wiring the image build into `incus_image`/`incus_instance` |
| `flake.nix` | Evaluates both and exposes the plan/apply/destroy commands |

## Diffing using dix

```sh
# if the container was build on the same machine, it should be in our local store
RUNNING=$(incus exec <container> -- readlink -f /run/current-system)
# sanity check
nix-store -qR "$RUNNING"
# if it's not, you might be able to copy it
# nix copy --from ssh-ng://root@<container> "$RUNNING"
# can use incus file pull "$RUNNING" or incus file mount "$RUNNING" running-system if ssh is not available


# need new toplevel in store for comparison, can't compare squashfs tarballs
NEW=$(nix build ".#nixosConfigurations.hello.config.system.build.toplevel" --print-out-paths --no-link)

# compare
dix --force-correctness --output json $RUNNING $NEW
```
