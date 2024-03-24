# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  pkgs,
  config,
  ...
}: {
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # If you want to use modules from other flakes (such as nixos-hardware):
    inputs.hardware.nixosModules.raspberry-pi-4
    inputs.sops-nix.nixosModules.sops

    # You can also split up your configuration and import pieces of it here:
    ../common/nix.nix
    ../common/zsh.nix
    ./services
    ./bluetooth-audio.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      #outputs.overlays.additions
      #outputs.overlays.modifications
      #outputs.overlays.unstable-packages

      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
  };

  networking = {
    hostName = "rpi4";
    useDHCP = true;
  };

  networking.wireless = {
    enable = true;
    environmentFile = config.sops.secrets.wireless.path;
    networks."THENEST" = {
      psk = "@PSK_THENEST@";
    };
  };
  sops.secrets.wireless = {};

  # Set your time zone.
  time.timeZone = "America/Edmonton";

  environment.systemPackages = with pkgs; [
    # rpi utils
    raspberrypi-eeprom
    libraspberrypi

    # utils
    neovim
    ncdu
    ranger
    htop
    git
    pciutils
  ];

  users = {
    #mutableUsers = false; # TODO
    users = {
      hyshka = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.hyshka_password.path;
        extraGroups = ["wheel"];
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCTi8LybJv9rM1PY+89RizysnNS0qe17peP1lsribcY+VuEW1aZrjYePJKVyFlIUqQnPGr9zK2FsLqU+Y40hfNQMITlHQMCbrWLvGdPvR2uP17+DFvZSp+ox0KVIjqOgxpLIWbszHKzfA1g8FJfzpH7j1kzP7bEonUXAGd3eVtf2kuzELKl7pI4uQyuoKF6ti1EMKQEOivLJm9aphz8/Bk+aZVgFy2srCxhqpWM5v967iNOK+UtPAqStrkJTvc1NtmMe6YQ099lRltq5dLerBfb0r5BdTKa+oTrgMELzV1YOv1i5Nj21RUz0kDT1eiVoqmyYAIlB8Rn01qByCU+2FH1 bryan@hyshka.com"
        ];
        # TODO move to shell module
        shell = pkgs.zsh;
      };
      # For remote deployments as root
      root.openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCTi8LybJv9rM1PY+89RizysnNS0qe17peP1lsribcY+VuEW1aZrjYePJKVyFlIUqQnPGr9zK2FsLqU+Y40hfNQMITlHQMCbrWLvGdPvR2uP17+DFvZSp+ox0KVIjqOgxpLIWbszHKzfA1g8FJfzpH7j1kzP7bEonUXAGd3eVtf2kuzELKl7pI4uQyuoKF6ti1EMKQEOivLJm9aphz8/Bk+aZVgFy2srCxhqpWM5v967iNOK+UtPAqStrkJTvc1NtmMe6YQ099lRltq5dLerBfb0r5BdTKa+oTrgMELzV1YOv1i5Nj21RUz0kDT1eiVoqmyYAIlB8Rn01qByCU+2FH1 bryan@hyshka.com"
      ];
    };
  };

  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets.hyshka_password = {
    neededForUsers = true;
  };

  system.stateVersion = "23.11";
}
