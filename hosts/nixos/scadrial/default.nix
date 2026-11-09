{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    inputs.hardware.nixosModules.raspberry-pi-4
    ./hardware-configuration.nix
    ../common/global
  ];

  networking.hostName = "scadrial";

  boot.tmp.useTmpfs = true;

  services.journald.settings.Journal = {
    Storage = "volatile";
    RuntimeMaxUse = "64M";
  };

  networking.wireless = {
    enable = true;
    secretsFile = config.sops.secrets.wireless.path;
    networks."THENEST" = {
      psk = "@PSK_THENEST@";
    };
  };
  sops.secrets.wireless = { };

  environment.systemPackages = with pkgs; [
    # rpi utils
    raspberrypi-eeprom
    libraspberrypi

    # utils
    neovim
    ncdu_1
    yazi
    htop
    git
    pciutils
  ];

  users = {
    users = {
      hyshka = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.hyshka_password.path;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = lib.splitString "\n" (builtins.readFile ../../../home/hyshka/ssh.pub);
        shell = pkgs.zsh;
      };
      # For remote deployments as root
      root.openssh.authorizedKeys.keys = lib.splitString "\n" (
        builtins.readFile ../../../home/hyshka/ssh.pub
      );
    };
  };

  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets.hyshka_password = {
    neededForUsers = true;
  };

  system.stateVersion = "26.05";
}
