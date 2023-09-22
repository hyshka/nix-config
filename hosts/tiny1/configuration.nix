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
    firewall = {
      allowedTCPPorts = [ 80 443 22000 38000 ];
      # TODO move to module
      # docker interface for mediacenter network, allows docker to access ntfy
      interfaces."br-65ee147cd7f3".allowedTCPPorts = [ 8010 ];
    };
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

  # TODO move to nginx?
  security.acme = {
    acceptTerms = true;
    defaults.email = "bryan@hyshka.com";
  };

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
      # TODO move to services
      wireguard = {
        isSystemUser = true;
        uid = 13001;
        group = "mediacenter";
      };
      qbittorrent = {
        isSystemUser = true;
        uid = 13002;
        group = "mediacenter";
      };
      sonarr = {
        isSystemUser = true;
        uid = 13003;
        group = "mediacenter";
      };
      radarr = {
        isSystemUser = true;
        uid = 13004;
        group = "mediacenter";
      };
      jellyfin = {
        isSystemUser = true;
        uid = 13006;
        group = "mediacenter";
        # Unsure if video is required for hardware accel
        extraGroups = [ "video" ];
      };
      recyclarr = {
        isSystemUser = true;
        uid = 13007;
        group = "mediacenter";
      };
      jellyseer = {
        isSystemUser = true;
        uid = 13008;
        group = "mediacenter";
      };
      prowlarr = {
        isSystemUser = true;
        uid = 13009;
        group = "mediacenter";
      };
    };
    groups = {
      mediacenter = {
        gid = 13000;
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
