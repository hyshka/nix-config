# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)

{ inputs, outputs, pkgs, config, ... }: {
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # If you want to use modules from other flakes (such as nixos-hardware):
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-cpu-intel-kaby-lake
    inputs.sops-nix.nixosModules.sops

    # You can also split up your configuration and import pieces of it here:
    ../common/nix.nix
    ../common/zsh.nix
    ./services

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "tiny1";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "America/Edmonton";

  environment.systemPackages = with pkgs; [
      # utils
      neovim ncdu ranger htop git pciutils

      # mergerfs tools
      mergerfs mergerfs-tools fuse

      # btrfs tools
      btrfs-progs snapper

      # disk tools
      nvme-cli smartmontools fio hdparm iozone parted

      # misc?
      fontconfig glibc
  ];

  users = {
    #mutableUsers = false; # TODO
    users = {
      hyshka = {
        isNormalUser = true;
        passwordFile = config.sops.secrets.hyshka_password.path;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCTi8LybJv9rM1PY+89RizysnNS0qe17peP1lsribcY+VuEW1aZrjYePJKVyFlIUqQnPGr9zK2FsLqU+Y40hfNQMITlHQMCbrWLvGdPvR2uP17+DFvZSp+ox0KVIjqOgxpLIWbszHKzfA1g8FJfzpH7j1kzP7bEonUXAGd3eVtf2kuzELKl7pI4uQyuoKF6ti1EMKQEOivLJm9aphz8/Bk+aZVgFy2srCxhqpWM5v967iNOK+UtPAqStrkJTvc1NtmMe6YQ099lRltq5dLerBfb0r5BdTKa+oTrgMELzV1YOv1i5Nj21RUz0kDT1eiVoqmyYAIlB8Rn01qByCU+2FH1 bryan@hyshka.com"
        ];
        # TODO move to shell module
        shell = pkgs.zsh;
      };
    };
  };

  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets.hyshka_password = {
    sopsFile = ./secrets.yaml;
    neededForUsers = true;
  };

  system.stateVersion = "23.05";
}
