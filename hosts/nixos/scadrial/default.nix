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
    ../common/appliance-utils.nix

    ./services
  ];

  networking.hostName = "scadrial";

  boot.tmp.useTmpfs = true;

  services.journald.settings.Journal = {
    Storage = "volatile";
    RuntimeMaxUse = "64M";
  };

  environment.systemPackages = with pkgs; [
    # rpi utils
    raspberrypi-eeprom
    libraspberrypi
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
    };
  };

  services.openssh.hostKeys = [
    {
      type = "ed25519";
      path = "/boot/firmware/ssh/ssh_host_ed25519_key";
    }
  ];

  # For remote deployments as root
  services.openssh.settings.PermitRootLogin = "yes";
  users.users.root.openssh.authorizedKeys.keys = lib.splitString "\n" (
    builtins.readFile ../../../home/hyshka/ssh.pub
  );

  sops.defaultSopsFile = ./secrets.yaml;
  sops.age.sshKeyPaths = [ "/boot/firmware/ssh/ssh_host_ed25519_key" ];
  sops.secrets.hyshka_password = {
    neededForUsers = true;
  };

  system.stateVersion = "26.05";
}
