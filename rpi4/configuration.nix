# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)

{ inputs, outputs, pkgs, config, ... }: {
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # If you want to use modules from other flakes (such as nixos-hardware):
    inputs.hardware.nixosModules.raspberry-pi-4
    inputs.sops-nix.nixosModules.sops

    # You can also split up your configuration and import pieces of it here:
    ./services
    ./psitransfer.nix # TODO move nixos config module to ./modules

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  # TODO use common module
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs = {
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # TODO slim down packages, go headless
  # environment.noXlibs = mkDefault true;

  networking = {
    hostName = "rpi4-nixos";
    firewall = {
      allowedTCPPorts = [ 80 443 22000 38000 ];
      # docker interface for mediacenter network, allows docker to access ntfy
      interfaces."br-65ee147cd7f3".allowedTCPPorts = [ 8010 ];
    };
  };

  environment.systemPackages = with pkgs; [
  	# rpi utils
      raspberrypi-eeprom libraspberrypi

      # utils
      neovim ncdu ranger htop git pciutils

      # filesystem
      btrfs-progs fuse snapper
      # hard disk tools
      smartmontools fio hdparm iozone parted

      # misc
      fontconfig glibc

      # docker
      docker-compose

      # services
      syncthing
      nginx
      restic # TODO configure
      ddclient
      psitransfer
      ntfy-sh
      glances
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "bryan@hyshka.com";
  };

  users = {
    mutableUsers = false;
    users = {
      hyshka = {
        isNormalUser = true;
        passwordFile = config.sops.secrets.hyshka_password.path;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCTi8LybJv9rM1PY+89RizysnNS0qe17peP1lsribcY+VuEW1aZrjYePJKVyFlIUqQnPGr9zK2FsLqU+Y40hfNQMITlHQMCbrWLvGdPvR2uP17+DFvZSp+ox0KVIjqOgxpLIWbszHKzfA1g8FJfzpH7j1kzP7bEonUXAGd3eVtf2kuzELKl7pI4uQyuoKF6ti1EMKQEOivLJm9aphz8/Bk+aZVgFy2srCxhqpWM5v967iNOK+UtPAqStrkJTvc1NtmMe6YQ099lRltq5dLerBfb0r5BdTKa+oTrgMELzV1YOv1i5Nj21RUz0kDT1eiVoqmyYAIlB8Rn01qByCU+2FH1 bryan@hyshka.com"
      ];
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

  # TODO pull in home manager tmux
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    shortcut = "Space";
    baseIndex = 1;
    aggressiveResize = true;
    escapeTime = 10;
    plugins = with pkgs; [ tmuxPlugins.sensible tmuxPlugins.pain-control tmuxPlugins.sessionist tmuxPlugins.tmux-colors-solarized ];
    extraConfig = ''
      set -g @colors-solarized 'light'
    '';
  };

  sops.secrets.hyshka_password = {
    sopsFile = ./secrets.yaml;
    neededForUsers = true;
  };

  system.stateVersion = "23.05";
}
