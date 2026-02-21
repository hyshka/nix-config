{ inputs, ... }:
{
  imports = [
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-cpu-amd-pstate
    inputs.hardware.nixosModules.common-gpu-amd

    ./hardware-configuration.nix

    ../common/global
    ../common/users/hyshka

    ../common/android.nix
    ../common/pipewire.nix
    ../common/plasma.nix
    ../common/wireless.nix

    ./docker.nix
    ./doom.nix
    ./steam.nix
    ./sunshine.nix
    ./syncthing.nix
    ./wol.nix
  ];

  networking.hostName = "starship";

  hardware.graphics.enable = true;
  hardware.bluetooth = {
    enable = true;
  };

  services.displayManager.autoLogin = {
    enable = true;
    user = "hyshka";
  };

  sops.defaultSopsFile = ./secrets.yaml;

  system.stateVersion = "23.11";
}
