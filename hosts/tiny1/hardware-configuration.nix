{lib, ...}: {
  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

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
      device = "/dev/nvme0n1p1";
      fsType = "ext4";
      options = ["defaults" "noatime"];
    };
    "/boot" = {
      device = "/dev/nvme0n1p3";
      fsType = "vfat";
      options = ["defaults" "noatime"];
    };
    "/mnt/disk1" = {
      # newer drive, no errors: /dev/disk/by-id/usb-WD_Elements_2621_57584A3241363146314A4858-0:0-part1
      device = "/dev/disk/by-id/usb-WD_Elements_2621_57584A3241363146314A4858-0:0-part1";
      # older drive, some read errors: /dev/disk/by-id/usb-WD_Elements_1078_575831314141343244544855-0:0-part1
      fsType = "btrfs";
      options = ["defaults" "noatime"];
    };
    "/mnt/disk2" = {
      # older drive, some read errors: /dev/disk/by-id/usb-WD_Elements_1078_575831314141343244544855-0:0-part1
      device = "/dev/disk/by-id/usb-WD_Elements_1078_575831314141343244544855-0:0-part1";
      fsType = "btrfs";
      options = ["defaults" "noatime"];
    };
    "/mnt/disk3" = {
      device = "/dev/disk/by-id/usb-ST4000VN_006-3CW104_152D00539000-0:1-part1";
      fsType = "btrfs";
      options = ["defaults" "noatime"];
    };
    "/mnt/storage" = {
      device = "/mnt/disk*";
      fsType = "fuse.mergerfs";
      options = [
        "defaults"
        # partial cache required for mmap support for qbittorrent
        # ref: https://github.com/trapexit/mergerfs#you-need-mmap-used-by-rtorrent-and-many-sqlite3-base-software
        "cache.files=partial"
        "dropcacheonclose=true"
        "category.create=mfs"
        "fsname=mergerfs"
        # TODO enable once I actually have free space
        #"minfreespace=200G"
      ];
    };
    "/mnt/parity1" = {
      device = "/dev/disk/by-id/usb-WDC_WD40_EFPX-68C6CN0_152D00539000-0:0-part1";
      # https://www.snapraid.it/faq#fs
      # mkfs.ext4 -m 0 -T largefile4 DEVICE
      fsType = "ext4";
      options = ["defaults" "noatime"];
    };
  };

  swapDevices = [
    {
      device = "/dev/nvme0n1p2"; # 4GB
      priority = 1; # needs to be lower than the default zram priority of 5
    }
  ];
  zramSwap.enable = true;

  nixpkgs.hostPlatform = "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
