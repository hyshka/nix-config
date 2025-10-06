{
  imports = [
    ./hardware-configuration.nix
    ./graphics.nix
    ./keyboard.nix
    ./syncthing.nix

    ../common/global
    ../common/users/hyshka

    ../common/optional/android.nix
    ../common/optional/pipewire.nix
    ../common/optional/plasma.nix
    ../common/optional/powertop.nix
    ../common/optional/wireless.nix
    ../common/optional/nixremote_local.nix
  ];

  networking.hostName = "ashyn";
  sops.defaultSopsFile = ./secrets.yaml;

  # https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "24.05";
}
