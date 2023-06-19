{ pkgs, config, ... }:
{
  # Support user desktops
  xdg.portal = {
    enable = true;
    # allow screen sharing with wlroots compositors
    wlr.enable = true; # required for flameshot
    #extraPortals = [
    #  pkgs.xdg-desktop-portal-gtk # TODO test removal
    #];
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
    #wireplumber.enable = true; # TODO test removal; required by xdg-desktop-portal-wlr
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

  # Gparted support
  security.polkit.enable = true;
  environment.systemPackages = with pkgs; [ polkit_gnome ];
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
    };
  };

  # Enable steam
  programs.steam = {
    enable = true;
    #remotePlay.openFirewall = true;
  };

  # Enable avahi for Sunshine
  services.avahi = {
    enable = true;
    reflector = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      userServices = true;
      workstation = true;
    };
  };
  services.udev.extraRules = ''
  KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess"
  '';

  # Enable KMS access for Sunshine
  #security.wrappers.sunshine = {
  #  owner = "root";
  #  group = "root";
  #  capabilities = "cap_sys_admin+p";
  #  source = "${pkgs.sunshine}/bin/sunshine";
  #};
  #systemd.user.services.sunshine = {
  #  #enable = false;
  #  description = "sunshine";
  #  wantedBy = [ "graphical-session.target" ];
  #  serviceConfig = {
  #    ExecStart = "${config.security.wrapperDir}/sunshine";
  #  };
  #};
  services.flatpak.enable = true;

  # TODO this didn't work in my home manager config
  programs.openvpn3.enable = true; # work VPN access
  services.openvpn.servers = {
    workVPN  = {
      autoStart = false;
      config = '' config /home/hyshka/work/MR/bryan.ovpn '';
    };
  };
}
