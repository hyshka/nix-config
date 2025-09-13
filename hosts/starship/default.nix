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

  # Allow outdated Darktable version to build
  nixpkgs.config.permittedInsecurePackages = [
    "libsoup-2.74.3"
    "qtwebengine-5.15.19"
  ];
}
