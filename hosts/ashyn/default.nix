{
  imports = [
    ./hardware-configuration.nix
    ./graphics.nix
    ./keyboard.nix

    ../common/global
    ../common/users/hyshka

    ../common/optional/android.nix
    ../common/optional/pipewire.nix
    ../common/optional/plasma.nix
    ../common/optional/powertop.nix
    ../common/optional/wireless.nix
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "deskflow-1.18.0"
  ];

  networking.hostName = "ashyn";

  # https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "24.05";
}
