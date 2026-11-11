{
  pkgs,
  lib,
  ...
}:
{
  boot.kernelPackages = pkgs.linuxPackages;

  boot.kernel.sysctl = {
    # optimize swap for zram
    # https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };

  zramSwap.enable = true;

  hardware.raspberry-pi.firmware = {
    enable = true;
    uboot.enable = true;

    package = pkgs.raspberrypifw.overrideAttrs (prev: {
      installPhase = prev.installPhase + ''
        boot=$out/share/raspberrypi/boot
        find "$boot" -maxdepth 1 -type f -name 'kernel*.img' -delete
        find "$boot" -maxdepth 1 -type f -name 'start*.elf' ! -name 'start4.elf' -delete
        find "$boot" -maxdepth 1 -type f -name 'fixup*.dat' ! -name 'fixup4.dat' -delete
        find "$boot" -maxdepth 1 -type f -name '*.dtb' ! -name 'bcm2711-rpi-*.dtb' -delete
      '';
    });
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  fileSystems."/boot/firmware" = {
    device = "/dev/disk/by-label/FIRMWARE";
    fsType = "vfat";
    options = lib.mkForce [
      "umask=0077"
      "nofail"
    ];
  };

  nixpkgs.hostPlatform.system = "aarch64-linux";
}
