{inputs, ...}: {
  imports = [
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-cpu-amd-pstate
    inputs.hardware.nixosModules.common-gpu-amd

    ./hardware-configuration.nix

    ../common/global
    ../common/users/hyshka

    ../common/optional/android.nix
    ../common/optional/pipewire.nix

    ./bluetooth.nix
    ./desktop.nix
    ./docker.nix
    ./doom.nix
    ./gparted.nix
    ./steam.nix
    ./sunshine.nix
    ./syncthing.nix
    #./synergy.nix
    #./wol.nix
  ];

  networking.hostName = "starship";

  networking.firewall.enable = false;

  sops.defaultSopsFile = ./secrets.yaml;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
