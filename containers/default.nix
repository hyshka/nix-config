{
  lib,
  inputs,
  ...
}:
{
  mkContainer =
    {
      name,
      stateVersion ? "23.11",
    }:
    {
      imports = [
        "${inputs.nixpkgs}/nixos/modules/virtualisation/lxc-container.nix"
        inputs.sops-nix.nixosModules.sops
        inputs.impermanence.nixosModules.impermanence
      ];

      # Base configuration
      networking = {
        hostName = name;
      };
      system.stateVersion = stateVersion;

      # Ensure directory exists early in boot
      system.activationScripts.createSSHHostKeysDir = lib.mkBefore ''
        mkdir -p /persist/etc/ssh
      '';

      # Sops needs acess to the keys before the persist dirs are even mounted; so
      # just persisting the keys won't work, we must point both at /persist
      # https://github.com/nix-community/impermanence/issues/282
      services.openssh.hostKeys = [
        {
          path = "/persist/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];

      # incus config device add paperless persist disk source=/persist/microvms/paperless path=/persist shift=true
      # Device only exists at runtime, fake it for now to build the rootfs
      fileSystems."/persist" = {
        mountPoint = "/persist";
        device = "none";
        fsType = "none";
        options = [ "bind" ];
        neededForBoot = lib.mkForce true;
      };
    };
}
