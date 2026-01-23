{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-cpu-intel-kaby-lake

    ./hardware-configuration.nix

    ../common/global
    ../common/users/hyshka
    ../common/nixremote.nix

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
    parted
    nvme-cli
    smartmontools
    fio
    hdparm
    sdparm
    #iozone # TODO: build error

    # for intel_gpu_top
    intel-gpu-tools

    # misc utils
    usbutils # lsusb
    pciutils # lspci
    glibc # ldd, sprof
  ];

  # For remote deployments as root
  services.openssh.settings.PermitRootLogin = "yes";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCTi8LybJv9rM1PY+89RizysnNS0qe17peP1lsribcY+VuEW1aZrjYePJKVyFlIUqQnPGr9zK2FsLqU+Y40hfNQMITlHQMCbrWLvGdPvR2uP17+DFvZSp+ox0KVIjqOgxpLIWbszHKzfA1g8FJfzpH7j1kzP7bEonUXAGd3eVtf2kuzELKl7pI4uQyuoKF6ti1EMKQEOivLJm9aphz8/Bk+aZVgFy2srCxhqpWM5v967iNOK+UtPAqStrkJTvc1NtmMe6YQ099lRltq5dLerBfb0r5BdTKa+oTrgMELzV1YOv1i5Nj21RUz0kDT1eiVoqmyYAIlB8Rn01qByCU+2FH1 bryan@hyshka.com"
  ];

  sops.defaultSopsFile = ./secrets.yaml;

  system.stateVersion = "23.11";
}
