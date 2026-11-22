{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-cpu-intel-cpu-only
    # module emits a harmless warning, eventual removal will fail outright
    # trace: warning: common-gpu-intel-kaby-lake flake output is deprecated and will be removed. See https://github.com/NixOS/nixos-hardware/issues/992 for more information
    inputs.hardware.nixosModules.common-gpu-intel-kaby-lake

    ./hardware-configuration.nix

    ../common/global
    ../common/nixremote.nix
    ../common/appliance-utils.nix
    ../common/users/hyshka/appliance.nix

    ./services
  ];

  networking = {
    hostName = "tiny1";
    useNetworkd = true; # required for incus
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.memtest86.enable = true;

  environment.systemPackages = with pkgs; [
    # mergerfs tools
    mergerfs
    mergerfs-tools
    fuse

    # btrfs tools
    btrfs-progs
    snapper

    # disk tools
    nvme-cli

    # for intel_gpu_top
    intel-gpu-tools
    libva-utils

    # misc utils
    glibc # ldd, sprof
  ];

  sops.defaultSopsFile = ./secrets.yaml;

  system.stateVersion = "23.11";
}
