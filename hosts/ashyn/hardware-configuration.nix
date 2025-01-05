{
  inputs,
  config,
  lib,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "usb_storage" "sd_mod" "sdhci_pci"];
  boot.initrd.kernelModules = ["i915"];
  boot.kernelModules = ["kvm-intel"];
  boot.kernelParams = [
    # offload some media encoding to the GPU
    "i915.enable_guc=2"
  ];
  boot.kernel.sysctl = {
    # optimize swap on zram
    # https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };
  boot.extraModulePackages = [];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Allow cross-compiling for rpi4
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  zramSwap.enable = true;

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/mmcblk1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                passwordFile = "/tmp/secret.key"; # Interactive
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap.swapfile = {
                        size = "3G"; # https://itsfoss.com/swap-size/
                        priority = 1; # needs to be lower than the default zram priority of 5
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
