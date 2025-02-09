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
    ../common/optional/plasma.nix

    ./docker.nix
    ./doom.nix
    ./steam.nix
    #./sunshine.nix
    ./syncthing.nix
    #./wol.nix
  ];

  networking.hostName = "starship";

  hardware.graphics.enable = true;
  hardware.bluetooth = {
    enable = true;
  };

  sops.defaultSopsFile = ./secrets.yaml;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
