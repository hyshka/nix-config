{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
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
        "text/html" = ["firefox-devedition.desktop"];
        "text/xml" = ["firefox-devedition.desktop"];
        "x-scheme-handler/http" = ["firefox-devedition.desktop"];
        "x-scheme-handler/https" = ["firefox-devedition.desktop"];
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
    unstable.darktable
    hugin
    inkscape-with-extensions
    gimp-with-plugins
    digikam
    imv

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
    #sunshine
    #xorg.xrandr # required for sunshine
    #util-linux # required for sunshine/setsid
    #etlegacy # can't install 32 bit version on 64 bit OS for TC:E

    # misc
    yubikey-manager
    corectrl
    gparted
    xorg.xhost # required by gparted
    heimdall
    sway-contrib.grimshot # screenshots
    flameshot # screenshots
    grim # required for flameshot
    pavucontrol # volume controls
    xdg-utils # to fix programs launching other programs
    pkgs.unstable.uair # pomodoro timer
    libnotify # required to send notifications from uair to mako
    gnome.pomodoro

    # work
    fontforge-gtk
    zeal
    # work build deps
    # TODO move to module
    gnumake
    awscli2
    pre-commit
    python310Packages.nodeenv # for node.js pre-commit hooks
  ];

  xdg.configFile = {
    "uair" = {
      text = ''
        [defaults]
        format = "{time}\n"

        [[sessions]]
        id = "work"
        name = "Work"
        duration = "50m"
        command = "notify-send 'Work Done!'"

        [[sessions]]
        id = "rest"
        name = "Rest"
        duration = "10m"
        command = "notify-send 'Rest Done!'"
      '';
      target = "uair/uair.toml";
    };
  };

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
    extraSessionCommands = ''
      # https://github.com/flameshot-org/flameshot/blob/master/docs/Sway%20and%20wlroots%20support.md#basic-steps
      export SDL_VIDEODRIVER=wayland
      export _JAVA_AWT_WM_NONREPARENTING=1
      export QT_QPA_PLATFORM=wayland
      export XDG_SESSION_DESKTOP=sway
    '';
    extraConfig = ''
      # https://github.com/flameshot-org/flameshot/blob/master/docs/Sway%20and%20wlroots%20support.md#basic-steps
      exec systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK
      exec hash dbus-update-activation-environment 2>/dev/null && \
        dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK
    '';
    config = {
      modifier = "Mod4";
      menu = "wofi --show run";
      bars = [
        {
          command = "waybar";
        }
      ];
      assigns = {
        "1" = [{class = "^Slack$";}];
        "2" = [];
        "3" = [{class = "^Spotify$";}];
        "4" = [{app_id = "^firefox-aurora$";} {class = "^Chromium-browser";}];
        "5" = [];
      };
      window.commands = [
        # generic X11 dialogs
        {
          command = "floating enable";
          criteria = {
            window_type = "dialog";
            window_role = "dialog";
          };
        }
        # For pop up notification windows that don't use notifications api
        {
          command = "border none, floating enable";
          criteria = {
            title = "^zoom$";
          };
        }
        # For specific Zoom windows
        {
          command = "border pixel, floating enable";
          criteria = {
            title = "^(Zoom|About)$";
          };
        }
        {
          command = "floating enable, floating_minimum_size 960 x 700";
          criteria = {
            title = "Settings";
          };
        }
        # Open Zoom Meeting windows on a new workspace (a bit hacky)
        {
          # this just sends it to workspace 1
          command = "workspace next_on_output --create, move container to workspace current, floating disable, inhibit_idle open";
          criteria = {
            title = "Zoom Meeting(.*)?";
          };
        }
      ];
      output.Virtual-1 = {
        mode = "1920x1200";
        pos = "0 0";
      };
      keybindings = let
        modifier = config.wayland.windowManager.sway.config.modifier;
      in
        lib.mkOptionDefault {
          # Desktop Utilities
          "${modifier}+c" = "exec ${pkgs.clipman}/bin/clipman pick -t wofi";
          #"${modifier}+Shift+s" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot copy area";
          "${modifier}+Shift+s" = "exec ${pkgs.flameshot}/bin/flameshot gui";

          # Main app shortcuts
          "${modifier}+Shift+w" = "exec ${pkgs.firefox-devedition-bin}/bin/firefox-devedition";
          "${modifier}+Shift+v" = "exec ${pkgs.pavucontrol}/bin/pavucontrol";
        };
    };
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        height = 30;
        modules-left = ["sway/workspaces" "sway/mode" "sway/scratchpad"];
        modules-center = ["sway/window"];
        modules-right = ["custom/uair" "clock" "tray"];
        # requires uair package
        "custom/uair" = {
          format = "{}";
          max-length = 10;
          exec = "uair";
          on-click = "uairctl toggle";
        };
      };
    };
  };
  programs.swaylock.enable = true;
  programs.wofi.enable = true;
  services.swayidle.enable = true;
  services.mako = {
    enable = true;
    font = config.fontProfiles.sans-serif.family;
    defaultTimeout = 5;
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
