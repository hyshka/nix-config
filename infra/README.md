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
