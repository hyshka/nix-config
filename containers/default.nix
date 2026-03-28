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
        "${inputs.nixpkgs}/nixos/modules/profiles/image-based-appliance.nix"
        "${inputs.nixpkgs}/nixos/modules/profiles/perlless.nix"
        inputs.sops-nix.nixosModules.sops
        inputs.impermanence.nixosModules.impermanence
      ];

      # Base configuration
      networking = {
        hostName = name;
      };
      system.stateVersion = stateVersion;

      # incus config device add <container> sops-age-key disk \
      # source=tmpfs:/run/secrets/lxc-core-age-key \
      # path=/var/lib/sops-nix/key.txt \
      # readonly=true
      sops.age.keyFile = "/var/lib/sops-nix/key.txt";

      # incus config device add paperless persist disk source=/persist/microvms/paperless path=/persist shift=true
      # Device only exists at runtime, fake it for now to build the rootfs
      fileSystems."/persist" = {
        mountPoint = "/persist";
        device = "none";
        fsType = "none";
        options = [ "bind" ];
        neededForBoot = lib.mkForce true;
      };

      environment.persistence."/persist" = {
        directories = [
          "/var/lib/nixos" # persist uids/gids
        ];
      };

      # image-based-appliance.nix enforces networkd, only use resolved
      networking.useHostResolvConf = false;

      # override from lxc-container
      documentation.enable = lib.mkOverride 900 false;
      documentation.nixos.enable = lib.mkOverride 900 false;

      # reduce container size
      programs.bash.completion.enable = false;
      fonts.fontconfig.enable = false;
      appstream.enable = false;
      services.openssh.enable = false;

      # overlayfs mount requires CAP_SYS_ADMIN
      # can't go fully perlless until NixOS supports systemd-tmpfiles /etc management
      system.etc.overlay.enable = false;
      system.forbiddenDependenciesRegexes = lib.mkForce [ ];
    };
}
