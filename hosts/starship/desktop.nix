{
  pkgs,
  lib,
  ...
}: {
  # Support user desktops
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk # required for flameshot screenshot access
    ];
  };

  # Support auto mounting in Thunar
  # Use full-featured version instead of XFCE version
  services.gvfs = {
    enable = true;
    package = lib.mkForce pkgs.gnome.gvfs;
  };
  services.tumbler.enable = true; # Thumbnail support for images

  # video support
  hardware.graphics.enable = true;

  # xfce hack: https://nixos.wiki/wiki/Xfce#Pulseaudio
  nixpkgs.config.pulseaudio = true;

  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };
    # i3 is configured through home manager but this must be enabled so that it's
    # an option in the display manager
    windowManager.i3.enable = true;
  };
  services.displayManager.defaultSession = "xfce+i3";

  environment.systemPackages = with pkgs; [
    xfce.xfce4-pulseaudio-plugin
  ];
}
