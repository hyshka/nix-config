{
  # TODO try to OC
  boot.loader.raspberryPi.firmwareConfig = ''
      arm_boost=1
  '';

  # TODO fix crash https://github.com/NixOS/nixos-hardware/issues/631#issuecomment-1669557985
  boot.kernelParams = [ "kunit.enable=0" ];
  # https://github.com/NixOS/nixos-hardware/issues/631#issuecomment-1668650025
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

  # TODO smartctl tests & notifications
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "defaults" "noatime" ];
    };
    #"/mnt/disk1" = {
    #  # newer drive, no errors: /dev/disk/by-id/usb-WD_Elements_2621_57584A3241363146314A4858-0:0-part1
    #  device = "/dev/disk/by-id/usb-WD_Elements_2621_57584A3241363146314A4858-0:0-part1";
    #  # older drive, some read errors: /dev/disk/by-id/usb-WD_Elements_1078_575831314141343244544855-0:0-part1
    #  fsType = "btrfs";
    #  options = [ "defaults" "noatime" ];
    #};
    #"/mnt/disk2" = {
    #  # older drive, some read errors: /dev/disk/by-id/usb-WD_Elements_1078_575831314141343244544855-0:0-part1
    #  device = "/dev/disk/by-id/usb-WD_Elements_1078_575831314141343244544855-0:0-part1";
    #  fsType = "btrfs";
    #  options = [ "defaults" "noatime" ];
    #};
    #"/mnt/storage" = {
    #  device = "/mnt/disk*";
    #  fsType = "fuse.mergerfs";
    #  options = [
    #    "defaults"
    #    # partial cache required for mmap support for qbittorrent
    #    # ref: https://github.com/trapexit/mergerfs#you-need-mmap-used-by-rtorrent-and-many-sqlite3-base-software
    #    "cache.files=partial"
    #    "dropcacheonclose=true"
    #    "category.create=mfs"
    #    "fsname=mergerfs"
    #    # TODO enable once I actually have free space
    #    #"minfreespace=200G"
    #  ];
    #};
    #"/mnt/parity1" = {
    #  device = "/dev/disk/by-id/usb-WDC_WD40_EFPX-68C6CN0_152D00539000-0:0-part1";
    #  fsType = "ext4";
    #  options = [ "defaults" "noatime" ];
    #};
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
