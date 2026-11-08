{
  inputs,
  config,
  pkgs,
  ...
}:
let
  firmwareBoot = "${pkgs.raspberrypifw}/share/raspberrypi/boot";
in
{
  imports = [
    inputs.disko.nixosModules.disko
  ];

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
  };

  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/mmcblk0";
    content = {
      type = "table";
      format = "msdos";
      partitions = [
        {
          name = "FIRMWARE";
          part-type = "primary";
          fs-type = "fat32";
          start = "8M";
          end = "520M";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot/firmware";
            mountOptions = [ "umask=0077" ];
            postMountHook = ''
              set -euo pipefail
              shopt -s nullglob

              fw=/mnt/boot/firmware
              src=${firmwareBoot}

              mkdir -p "$fw/overlays"

              cp "$src"/bootcode.bin "$src"/start*.elf "$src"/fixup*.dat "$fw/"
              if compgen -G "$src/*.dtb" >/dev/null; then
                cp "$src"/*.dtb "$fw/"
              fi
              if compgen -G "$src/broadcom/*.dtb" >/dev/null; then
                cp "$src"/broadcom/*.dtb "$fw/"
              fi
              if compgen -G "$src/overlays/*" >/dev/null; then
                cp "$src"/overlays/* "$fw/overlays/"
              fi

              cp ${pkgs.ubootRaspberryPiAarch64}/u-boot.bin "$fw/"
              cp ${config.hardware.raspberry-pi.configtxt.file} "$fw/config.txt"
            '';
          };
        }
        {
          name = "root";
          part-type = "primary";
          fs-type = "ext4";
          start = "520M";
          end = "100%";
          bootable = true;
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
            mountOptions = [ "noatime" ];
          };
        }
      ];
    };
  };

  nixpkgs.hostPlatform.system = "aarch64-linux";
}
