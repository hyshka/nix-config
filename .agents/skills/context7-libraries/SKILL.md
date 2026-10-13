---
name: Context7 library map
description: Pick the right Context7 library ID and query for Nix, Terranix, OpenTofu/Terraform and the Incus provider/CLI
---

# Context7 library map

Use the Context7 MCP for upstream documentation instead of guessing. The tools
are `tools["context7"]["resolve-library-id"]` and `tools["context7"]["query-docs"]`.

Call `query-docs` directly with a known `libraryId`; only call
`resolve-library-id` when the ID is genuinely unknown. Keep each query to one
topic.

| Topic | libraryId | Use for | Example query |
| --- | --- | --- | --- |
| Nix language + CLI | `/nixos/nix` | syntax, builtins, flake/CLI behavior | "attrset merge semantics of the // operator" |
| Terranix | `/terranix/terranix` | generating Terraform/OpenTofu JSON from Nix; module and option merge behavior | "how the resource option merges across modules" |
| Incus provider (OpenTofu/Terraform) | `/lxc/terraform-provider-incus` | resource and attribute schema for `incus_instance`, `incus_storage_volume`, `incus_image`, ... | "incus_instance disk device properties and incus_storage_volume content_type" |
| Incus | `/lxc/incus` | incus CLI, config keys, devices, cloud-init, agent behavior | "security.secureboot config key and cloud-init in VMs" |

Pass `language` when ranking matters: `Nix`, `HCL`, or `Shell`.

## Traps

- Resolving by name is ambiguous. "Nix" also matches `/nix-rust/nix` (Rust
  bindings) and `/websites/nix_dev`; "incus" also matches `incus-compose` and
  `incus-os`; "terranix" has a second `/websites/terranix` entry. Use the exact
  IDs above rather than a bare name lookup.
- Context7 carries upstream schema only. Repo-specific decisions (the
  `image.baseName` vs `fileName` conflict, virtiofs vs block volume) live in
  this repo's docs and history, not there. Check those first.
