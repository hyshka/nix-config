{
  inputs,
  ...
}:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/virtualisation/incus-virtual-machine.nix"
    inputs.sops-nix.nixosModules.sops
    inputs.impermanence.nixosModules.impermanence
  ];

  # Base configuration
  system.stateVersion = "23.11";

  # Unlike the containers, a VM has no host bind-mount to inject a sops age key.
  # Derive the age identity deterministically from this VM's SSH host key, which
  # lives on the persistent data disk. Bootstrap once (in addition to the
  # per-image registration steps):
  #   incus exec forgejo-build-runner -- ssh-keygen -t ed25519 -N "" \
  #     -f /persist/etc/ssh/ssh_host_ed25519_key
  #   incus exec forgejo-build-runner -- cat /persist/etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age
  # then add that recipient to .sops.yaml and re-encrypt the image's secrets.
  sops.age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];

  # The data disk is attached by Incus at /persist (see each image's
  # resource.incus_instance in infra/<name>/default.nix). Mount it in the
  # initrd, otherwise the sops activation phase runs before Incus' agent mounts
  # the share and cannot read the age identity. The agent skips a mount point
  # that already exists.
  fileSystems."/persist" = {
    device = "incus_persist";
    fsType = "virtiofs";
    neededForBoot = true;
  };

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/nixos" # persist uids/gids
    ];
  };
}
