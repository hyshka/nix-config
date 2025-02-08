{
  lib,
  inputs,
  ...
}: {
  mkContainer = {
    name,
    stateVersion ? "23.11",
  }: {
    imports = [
      "${inputs.nixpkgs}/nixos/modules/virtualisation/lxc-container.nix"
      inputs.sops-nix.nixosModules.sops
      inputs.impermanence.nixosModules.impermanence
    ];

    # Base configuration
    networking.hostName = name;
    system.stateVersion = stateVersion;

    # Persistent host key for secrets
    services.openssh = {
      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };

    # incus config device add paperless persist disk source=/persist/microvms/paperless path=/persist shift=true
    # Device only exists at runtime, fake it for now to build the rootfs
    fileSystems."/persist" = {
      mountPoint = "/persist";
      device = "none";
      fsType = "none";
      options = ["bind"];
      neededForBoot = lib.mkForce true;
    };

    environment.persistence."/persist" = {
      files = [
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];
    };
  };
}
