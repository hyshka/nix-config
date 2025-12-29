{
  imports = [
    ./hardware-configuration.nix
    ./graphics.nix
    ./keyboard.nix
    ./syncthing.nix

    ../common/global
    ../common/users/hyshka

    ../common/android.nix
    ../common/ananicy.nix
    ../common/battery.nix
    ../common/earlyoom.nix
    ../common/nixremote_local.nix
    ../common/pipewire.nix
    ../common/sway.nix
    ../common/wireless.nix
  ];

  networking.hostName = "ashyn";
  sops.defaultSopsFile = ./secrets.yaml;

  # https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "24.05";
}
