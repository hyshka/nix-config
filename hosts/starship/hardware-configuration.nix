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

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s3.useDHCP = lib.mkDefault true;

  networking.wireless = {
    enable = false;
    # Temporarily enabling iwd and user control can help debug new networks.
    #iwd.enable = true;
    #userControlled.enable = true;
    environmentFile = config.sops.secrets.wireless.path;
    networks."THENEST" = {
      psk = "@PSK_THENEST@";
    };
  };
  sops.secrets.wireless = {};

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
