{ pkgs, ... }:
{
  # Support user desktops
  xdg.portal = {
    enable = true;
    # allow screen sharing with wlroots compositors
    wlr.enable = true;
  #  extraPortals = with pkgs; [
  #    xdg-desktop-portal-wlr
  #    xdg-desktop-portal-gtk
  #  ];
  };

  # Support auto mounting in Thunar
  services.gvfs.enable = true;

  # video support
  hardware = {
    opengl = {
      enable = true;
    };
  };

  # audio
  security.rtkit.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;
  };

  # Support Sway window manager
  programs.sway = {
    enable = true;
  };

  # autostart sway on login
  environment.loginShellInit = ''
    if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec sway -d >> sway.log 2>&1
    fi
  '';
}
