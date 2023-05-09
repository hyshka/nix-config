{ inputs, lib, config, pkgs, ... }: {
  home.packages = with pkgs; [
    # fonts
    iosevka-bin

    # web
    firefox-devedition-bin
    ungoogled-chromium

    # comms
    discord
    slack
    zoom-us

    # imaging
    darktable
    hugin
    inkscape-with-extensions
    gimp-with-plugins
    digikam

    # video
    #jellyfin-media-player
    mpv
    #handbrake
    #obs-studio
    #flowblade

    # office
    libreoffice
    flameshot
    zathura

    # file management
    xfce.thunar
    xfce.thunar-volman
    xfce.thunar-archive-plugin
    udiskie

    # networking
    #mullvad-vpn
    #transmission-gtk

    # music
    #spotify

    # gaming
    #steam
    #etlegacy

    # misc
    #yubikey-manager
    #corectrl
    #gparted
    #heimdall
    espanso

    # work
    fontforge-gtk
    zeal
  ];

  # Enable font discovery
  fonts.fontconfig.enable = true;
  gtk.font = "Iosevka Aile";

  #xdg.portal = {
  #  enable = true;
  #  extraPortals = with pkgs; [
  #    xdg-desktop-portal-wlr
  #    xdg-desktop-portal-gtk
  #  ];
  #};
  # allow swawylock to unlock
  #security.pam.services.swaylock = {
  #  text = "auth include login";
  #};

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    config = {
      modifier = "Mod4";
      terminal = "kitty";
      menu = "wofi --show run";
      startup = [
        {command = "kitty";}
      ];
      bars = [{
        fonts.size = 9.0;
        position = "top";
     }];
     output.Virtual-1 = {
       mode = "1920x1200";
       pos = "0 0";
     };
    };
  };

  programs.waybar.enable = true;
  programs.swaylock.enable = true;
  programs.wofi.enable = true;
  services.swayidle.enable = true;
  services.mako = {
    enable = true;
    font = "Iosevka Aile";
  };
  services.clipman.enable = true;
  services.udiskie.enable = true;
  services.espanso = {
    enable = true;
    settings = {
      matches = [
        {
          trigger = ":e1";
          replace = "bryan@hyshka.com";
        }
        {
          trigger = ":e2";
          replace = "bryan@muckrack.com";
        }
        {
          trigger = ":dr";
          replace = "python manage.py runserver 0.0.0.0:8000";
        }
        {
          trigger = ":dR";
          replace = "WEBPACK_LOADER_USE_PROD=1 python manage.py runserver 0.0.0.0:8000";
        }
        {
          trigger = ":dt";
          replace = "python manage.py test --keepdb --nomigrations";
        }
        {
          trigger = ":pdb";
          replace = "__import__('pdb').set_trace()  # FIXME";
        }
        {
          trigger = ":pudb";
          replace = "import pudb; pu.db  # FIXME";
        }
	{ # Dates
          trigger = ":date";
          replace = "{{mydate}}";
          vars = [{
            name = "mydate";
            type = "date";
            params = { format = "%Y-%m-%d"; };
          }];
        }
	{ # Shell commands
          trigger = ":shell";
          replace = "{{output}}";
          vars = [{
            name = "output";
            type = "shell";
            params = { cmd = "echo Hello from your shell"; };
          }];
        }
	{
          trigger = ":vim";
          replace = "{{output}}";
          vars = [{
            name = "output";
            type = "shell";
            params = { cmd = "kitty nvim"; };
          }];
        }
      ];
    };
  };

  programs.kitty = {
    enable = true;
    font = {
      size = 11;
      name = "Iosevka Term";
    };
    extraConfig = ''
      # Disable scrollback, I use tmux
      scrollback_lines 0
      scrollback_pager_history_size 0

      #detect_urls yes
      input_delay 0
      enable_audio_bell no
    '';
  };
}
