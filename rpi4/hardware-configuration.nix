{
  # TODO try to OC
  boot.loader.raspberryPi.firmwareConfig = ''
      arm_boost=1
  '';

  # TODO fix crash https://github.com/NixOS/nixos-hardware/issues/631#issuecomment-1669557985
  boot.kernelParams = [ "kunit.enable=0" ];
  https://github.com/NixOS/nixos-hardware/issues/631#issuecomment-1668650025
  # TODO fix nix build
  hardware.deviceTree.filter = "bcm2711-rpi-4*.dtb";

  # TODO slim down kernel modules, disable wireless
  # boot = {
  #         blacklistedKernelModules = [
  #           "btqca"
  #           "btsdio"
  #           "hci_uart"
  #           "btbcm"
  #           "bluetooth"
  #         ];
  # };

  boot.kernel.sysctl = {
    # optimize swap for zram
    # https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "defaults" "noatime" ];
    };
    "/mnt/btrfs" = {
      device = "/dev/disk/by-label/elements1";
      fsType = "btrfs";
      options = [ "defaults" "noatime" ];
    };
    "/mnt/storage" = {
      device = "/dev/disk/by-label/elements1";
      fsType = "btrfs";
      options = [ "defaults" "noatime" "subvol=storage" ];
    };
    "/mnt/psitransfer" = {
      device = "/dev/disk/by-label/elements1";
      fsType = "btrfs";
      options = [ "defaults" "noatime" "subvol=psitransfer" ];
    };
    "/mnt/mediacenter" = {
      device = "/dev/disk/by-label/elements1";
      fsType = "btrfs";
      options = [ "defaults" "noatime" "subvol=mediacenter" ];
    };
  };

  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 2*1024; # https://itsfoss.com/swap-size/
    priority = 1; # needs to be lower than the default zram priority of 5
  } ];
  zramSwap.enable = true;

  # Enable GPU acceleration for transcoding
  #hardware.raspberry-pi."4".fkms-3d.enable = true;

  nixpkgs.hostPlatform.system = "aarch64-linux";
}
