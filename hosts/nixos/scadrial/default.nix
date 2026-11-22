{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.hardware.nixosModules.raspberry-pi-4

    ./hardware-configuration.nix

    ../common/global
    ../common/nixremote.nix
    ../common/appliance-utils.nix
    ../common/users/hyshka/appliance.nix

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

  services.openssh.hostKeys = [
    {
      type = "ed25519";
      path = "/boot/firmware/ssh/ssh_host_ed25519_key";
    }
  ];

  sops.defaultSopsFile = ./secrets.yaml;
  sops.age.sshKeyPaths = [ "/boot/firmware/ssh/ssh_host_ed25519_key" ];

  system.stateVersion = "26.05";
}
