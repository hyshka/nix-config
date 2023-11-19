{
  pkgs,
  config,
  ...
}: {
  # Support user desktops
  xdg.portal = {
    enable = true;
    # allow screen sharing with wlroots compositors
    wlr.enable = true; # required for flameshot
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk # required for flameshot screenshot access
    ];
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
    wireplumber.enable = true; # TODO test removal; required by xdg-desktop-portal-wlr
  };

  # Support Sway window manager
  programs.sway = {
    enable = true;
  };

  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
      # TODO use i3
      #enableXfwm = false;
    };
    displayManager.defaultSession = "xfce";
    # TODO use i3
    #windowManager.i3.enable = true;

    #displayManager = {
    #  defaultSession = "none+i3";
    #};
    #windowManager.i3 = {
    #  enable = true;
    #  extraPackages = with pkgs; [
    #    dmenu #application launcher most people use
    #    i3status # gives you the default i3 status bar
    #    i3lock #default i3 screen locker
    #    i3blocks #if you are planning on using i3blocks over i3status
    # ];
    #};
  };

  # autostart sway on login
  environment.loginShellInit = ''
    if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec sway -d >> sway.log 2>&1
    fi
  '';

  # Gparted support
  security.polkit.enable = true;
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
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

  environment.systemPackages = with pkgs; [
    polkit_gnome # gparted support

    # sunshine
    unstable.sunshine
    xorg.xrandr # required for sunshine
    util-linux # required for sunshine/setsid
  ];

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
  hardware.steam-hardware.enable = true; # might replace uinput udev rule?
  services.udev.extraRules = ''
    KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess"
  '';

  # Enable KMS access for Sunshine
  security.wrappers.sunshine = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+ep";
    source = "${pkgs.sunshine}/bin/sunshine";
  };
  systemd.user.services.sunshine = {
    enable = false;
    script = "/run/current-system/sw/bin/env /run/wrappers/bin/sunshine";

    unitConfig = {
      Description = "Sunshine is a Game stream host for Moonlight.";
      StartLimitIntervalSec = 500;
      StartLimitBurst = 5;
    };

    serviceConfig = {
      Environment = "WAYLAND_DISPLAY=wayland-1";
      Restart = "on-failure";
      RestartSec = "5s";
      #ExecStart = "${config.security.wrapperDir}/sunshine";
    };
    wantedBy = [ "graphical-session.target" ];
  };
  services.flatpak.enable = true;

  # TODO this didn't work in my home manager config
  programs.openvpn3.enable = true; # work VPN access
  services.openvpn.servers = {
    workVPN = {
      autoStart = false;
      config = ''config /home/hyshka/work/MR/bryan.ovpn '';
    };
  };

  # TODO
  #systemd.services.wol = {
  #  enable = true;
  #  description = "Wake on LAN";
  #  unitConfig = {
  #    Requires = "network.target";
  #    After = "network.target";
  #  };
  #  serviceConfig = {
  #    Type = "oneshot";
  #    ExecStart = "${pkgs.ethtool}/bin/ethtool -s eno1 wol g";
  #  };
  #  wantedBy = [ "multi-user.target" ];
  #};
}
