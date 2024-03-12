{
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
      options = ["defaults" "noatime"];
    };
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 2 * 1024; # https://itsfoss.com/swap-size/
      priority = 1; # needs to be lower than the default zram priority of 5
    }
  ];
  zramSwap.enable = true;

  # Enable modesetting driver
  #hardware.raspberry-pi."4".fkms-3d.enable = true;

  nixpkgs.hostPlatform.system = "aarch64-linux";
}
