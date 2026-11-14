{ inputs, ... }:
{
  imports = [
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-cpu-amd-pstate
    inputs.hardware.nixosModules.common-gpu-amd

    ./hardware-configuration.nix

    ../../common/fonts.nix
    ../common/global
    ../common/global/catppuccin.nix
    ../common/users/hyshka

    ../common/android.nix
    ../common/pipewire.nix
    ../common/plasma.nix
    ../common/wireless.nix
    ../common/chrysalis.nix

    ./prometheus.nix
    ./docker.nix
    ./doom.nix
    ./steam.nix
    ./syncthing.nix
    ./incus.nix
    ./lact.nix
    ./forgejo-runner.nix
  ];

  networking.hostName = "starship";

  nix.settings = {
    min-free = "40G";
    max-free = "100G";
  };

  users.groups.nix-gc-roots = { };
  users.users.hyshka.extraGroups = [ "nix-gc-roots" ];

  systemd.tmpfiles.rules = [
    "d /var/lib/nix-gc-roots/images 2775 root nix-gc-roots -"
  ];

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
