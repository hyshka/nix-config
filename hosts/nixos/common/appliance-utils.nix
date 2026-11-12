{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # dev
    neovim
    yazi
    htop
    git

    # disk
    ncdu
    parted
    smartmontools

    # networking
    dig
    curl
    knot-dns
    openssl

    # devices
    usbutils
    pciutils
  ];
}
