{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = ["kvm-amd"];
  boot.kernel.sysctl = {
    # optimize swap on zram
    # https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };
  boot.extraModulePackages = [];

  # Allow cross-compiling for rpi4
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  # Disable systemd-boot and enable lanzaboote for secure boot support.
  boot = {
    loader.systemd-boot.enable = lib.mkForce false;
    loader.efi.canTouchEfiVariables = true;
    bootspec.enable = true;
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/b46bdeba-1da9-4cd2-a34b-827feb86b1e9";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/8DF7-8E89";
      fsType = "vfat";
    };
    #"/mnt/media" = {
    #  device = "/dev/disk/by-label/Media";
    #  fsType = "ntfs";
    #  options = [
    #    "uid=1000"
    #    "gid=100"
    #    "nofail"
    #  ];
    #};
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 6 * 1024; # https://itsfoss.com/swap-size/
      priority = 1; # needs to be lower than the default zram priority of 5
    }
  ];
  zramSwap.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
