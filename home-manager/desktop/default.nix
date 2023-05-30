{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ./font.nix
    ./gtk.nix
    ./qt.nix
    ./syncthing.nix
    #./xdg.nix
    #./espanso.nix
  ];

  # TODO move to module
  xdg = {
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = [ "firefox-devedition.desktop" ];
        "text/xml" = [ "firefox-devedition.desktop" ];
        "x-scheme-handler/http" = [ "firefox-devedition.desktop" ];
        "x-scheme-handler/https" = [ "firefox-devedition.desktop" ];
      };
    };
  };

  home.packages = with pkgs; [
    # web
    firefox-devedition-bin
    ungoogled-chromium

    # comms
    discord
    slack
    zoom-us # TODO can't sign in but can join video from zoom links

    # imaging
    darktable
    hugin
    inkscape-with-extensions
    gimp-with-plugins
    digikam

    # video
    jellyfin-media-player
    mpv
    handbrake
    obs-studio
    flowblade # TODO won't launch

    # office
    libreoffice
    zathura

    # file management
    xfce.thunar
    xfce.thunar-volman # requires gvfs
    xfce.thunar-archive-plugin

    # networking
    mullvad-vpn
    transmission-gtk

    # music
    spotify

    # gaming
    steam
    #etlegacy

    # misc
    yubikey-manager
    corectrl
    gparted
    heimdall
    sway-contrib.grimshot # screenshots

    # work
    fontforge-gtk
    zeal
    # work build deps
    # TODO mode to module
    gnumake
    awscli2
  ];

  # Enable font discovery
  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    #QT_QPA_PLATFORM = "wayland";
    LIBSEAT_BACKEND = "logind";
    #TERMINAL = "kitty -1";
    TERMINAL = "foot";
    BROWSER = "firefox-devedition";
  };

  wayland.windowManager.sway = {
    enable = true;
    package = null;
    wrapperFeatures.gtk = true;
    config = {
      modifier = "Mod4";
      #terminal = "kitty";
      menu = "wofi --show run";
      #startup = [
      #  {command = "kitty -1";}
      #];
      bars = [
        {
	  command = "waybar";
	}
      ];
     output.Virtual-1 = {
       mode = "1920x1200";
       pos = "0 0";
     };
     keybindings = let
        modifier = config.wayland.windowManager.sway.config.modifier;
      in lib.mkOptionDefault {
        "${modifier}+Shift+s" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot copy area";
      };
    };
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        height = 30;
	modules-left = [ "sway/workspaces" "sway/mode" "sway/scratchpad" ];
        modules-center = [ "sway/window" ];
        modules-right = [ "clock" "tray" ];
      };
    };
  };
  programs.swaylock.enable = true;
  programs.wofi.enable = true;
  services.swayidle.enable = true;
  services.mako = {
    enable = true;
    font = config.fontProfiles.sans-serif.family;
  };
  services.clipman.enable = true;
  #services.udiskie.enable = true;

  programs.foot = {
    enable = true;
  };

  programs.kitty = {
    enable = true;
    font = {
      size = 11;
      name = config.fontProfiles.monospace.family;
    };
    settings = {
      scrollback_lines = 0;
      scrollback_pager_history_size = 0;
      #detect_urls = "yes";
      input_delay = 0;
      enable_audio_bell = "no";
    };
  };
}
