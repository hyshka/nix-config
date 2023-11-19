# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # If you want to use modules from other flakes (such as nixos-hardware):
    #inputs.hardware.nixosModules.common-pc
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-cpu-amd
    #inputs.hardware.nixosModules.common-cpu-amd-pstate
    inputs.hardware.nixosModules.common-gpu-amd
    #inputs.hardware.nixosModules.common-hidpi
    inputs.sops-nix.nixosModules.sops
    inputs.lanzaboote.nixosModules.lanzaboote

    # You can also split up your configuration and import pieces of it here:
    ../common/nix.nix
    ../common/zsh.nix
    ./desktop.nix
    ./docker.nix
    ./sshd.nix
    ./users.nix
    ./bluetooth.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      #outputs.overlays.additions
      #outputs.overlays.modifications
      outputs.overlays.unstable-packages

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

  networking.hostName = "starship"; # Define your hostname.
  networking.firewall.enable = false;

  # TODO move to module
  networking.hosts = {
    "10.0.0.240" = [
      "jellyseer.hyshka.com"
      "jellyfin.hyshka.com"
      "ntfy.hyshka.com"
      "glances.hyshka.com"
      "dashboard.hyshka.com"
    ];
  };
  networking.wireless = {
    enable = true;
    #iwd.enable = true; # TODO remove once this works
    #userControlled.enable = true; # TODO remove once this works
    environmentFile = config.sops.secrets.wireless.path;
    networks."THENEST" = {
      psk = "@PSK_THENEST@";
    };
  };

  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets.wireless = {};

  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = lib.mkForce false;
    loader.efi.canTouchEfiVariables = true;
    bootspec.enable = true;
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
  };

  # Set your time zone.
  time.timeZone = "America/Edmonton";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  #environment.systemPackages = with pkgs; [];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
