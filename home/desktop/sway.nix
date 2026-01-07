{
  config,
  pkgs,
  lib,
  ...
}:
let
  modifier = config.wayland.windowManager.sway.config.modifier;
in
{
  wayland.windowManager.sway = {
    enable = true;
    systemd.variables = [ "--all" ];
    wrapperFeatures.gtk = true;

    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export _JAVA_AWT_WM_NONREPARENTING=1
      export QT_QPA_PLATFORM=wayland
      export XDG_SESSION_DESKTOP=sway
      export XDG_CURRENT_DESKTOP=sway
      export MOZ_ENABLE_WAYLAND=1
    '';

    extraConfig = ''
      focus_follows_mouse no
      default_border pixel 2
      default_floating_border pixel 2

      exec systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK
      exec hash dbus-update-activation-environment 2>/dev/null && \
        dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK
    '';

    config = {
      modifier = "Mod1"; # Alt key (user preference)
      terminal = "${pkgs.alacritty}/bin/alacritty";
      menu = "${pkgs.fuzzel}/bin/fuzzel";

      startup = [
        { command = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"; }
        { command = "${pkgs.blueman}/bin/blueman-applet"; }
      ];

      bars = [ { command = "${pkgs.waybar}/bin/waybar"; } ];

      input."*" = {
        xkb_layout = "us";
        xkb_options = "caps:escape";
        tap = "enabled";
      };

      output."*".bg = "#303446 solid_color";

      keybindings = lib.mkOptionDefault {
        # Applications
        "${modifier}+Shift+w" = "exec ${pkgs.brave}/bin/brave";
        "${modifier}+Shift+v" = "exec ${pkgs.pavucontrol}/bin/pavucontrol";

        # Clipboard
        "${modifier}+c" = "exec ${pkgs.clipman}/bin/clipman pick --tool STDOUT | fuzzel --dmenu | wl-copy";

        # Screenshots
        "${modifier}+Shift+s" =
          "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy";
        "Print" = "exec ${pkgs.grim}/bin/grim ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png";
        "${modifier}+Print" =
          "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png";

        # Lock
        "${modifier}+l" = "exec ${pkgs.swaylock}/bin/swaylock -f";

        # Brightness
        "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +5%";
        "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
        "${modifier}+F6" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +5%";
        "${modifier}+F5" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";

        # Volume
        "XF86AudioRaiseVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute" = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioMicMute" = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        "${modifier}+F3" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "${modifier}+F2" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "${modifier}+F1" = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };
    };
  };

  # Floating windows for specific applications
  wayland.windowManager.sway.config.floating.criteria = [
    {
      title = "Bitwarden"; # Bitwarden through browser
    }
  ];

  # Enhanced waybar with laptop modules
  programs.waybar = {
    enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 30;

      modules-left = [
        "sway/workspaces"
        "sway/mode"
        "sway/scratchpad"
      ];

      modules-center = [ "sway/window" ];

      modules-right = [
        "idle_inhibitor"
        "pulseaudio"
        "network"
        "backlight"
        "battery"
        "clock"
        "tray"
      ];

      "sway/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
      };

      "idle_inhibitor" = {
        format = "{icon}";
        format-icons = {
          activated = "󰈈";
          deactivated = "󰈉";
        };
      };

      backlight = {
        format = "{icon} {percent}%";
        format-icons = [
          "󰃞"
          "󰃟"
          "󰃠"
        ];
        on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl set +5%";
        on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
      };

      battery = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-plugged = "󰚥 {capacity}%";
        format-icons = [
          "󰁺"
          "󰁻"
          "󰁼"
          "󰁽"
          "󰁾"
          "󰁿"
          "󰂀"
          "󰂁"
          "󰂂"
          "󰁹"
        ];
        interval = 30;
      };

      network = {
        format-wifi = "󰤨 {essid} ({signalStrength}%)";
        format-ethernet = "󰈀 {ifname}";
        format-disconnected = "󰤭 Disconnected";
        tooltip-format = "{ifname}: {ipaddr}/{cidr}";
        on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰝟 muted";
        format-icons = {
          headphone = "󰋋";
          default = [
            "󰕿"
            "󰖀"
            "󰕾"
          ];
        };
        on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
      };

      clock = {
        format = "󰥔 {:%H:%M}";
        format-alt = "󰃭 {:%Y-%m-%d}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
        calendar = {
          mode = "month";
          format = {
            months = "<span color='#ffead3'><b>{}</b></span>";
            days = "<span color='#ecc6d9'><b>{}</b></span>";
            today = "<span color='#ff6699'><b><u>{}</u></b></span>";
          };
        };
      };

      tray = {
        icon-size = 16;
        spacing = 8;
      };
    };
  };

  # Swaylock
  programs.swaylock = {
    enable = true;
    settings = {
      color = "303446";
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      show-failed-attempts = true;
    };
  };

  # Swayidle with auto-suspend on battery
  services.swayidle = {
    enable = true;
    events = {
      "before-sleep" = "${pkgs.swaylock}/bin/swaylock -f";
      "lock" = "${pkgs.swaylock}/bin/swaylock -f";
    };
    timeouts = [
      {
        timeout = 300;
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
      {
        timeout = 600;
        command = "${pkgs.sway}/bin/swaymsg \"output * dpms off\"";
        resumeCommand = "${pkgs.sway}/bin/swaymsg \"output * dpms on\"";
      }
      {
        timeout = 1200;
        command = ''if [ "$(cat /sys/class/power_supply/BAT*/status)" = "Discharging" ]; then ${pkgs.systemd}/bin/systemctl suspend; fi'';
      }
    ];
  };

  # Fuzzel launcher
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "${pkgs.alacritty}/bin/alacritty";
        layer = "overlay";
        width = 40;
        horizontal-pad = 20;
        vertical-pad = 8;
        inner-pad = 8;
      };
      colors = {
        background = "303446dd";
        text = "c6d0f5ff";
        match = "e5c890ff";
        selection = "626880ff";
        selection-text = "c6d0f5ff";
        border = "babbf1ff";
      };
      border = {
        width = 2;
        radius = 8;
      };
    };
  };

  # Mako notifications
  services.mako = {
    enable = true;
    settings = {
      font = "${config.fontProfiles.sans-serif.family} 11";
      background-color = "#303446dd";
      text-color = "#c6d0f5";
      border-color = "#babbf1";
      border-radius = 8;
      border-size = 2;
      default-timeout = 5000;
      max-visible = 3;
      layer = "overlay";
    };
  };

  # Clipboard service
  services.clipman = {
    enable = true;
    systemdTarget = "sway-session.target";
  };

  # Blue light filter
  services.wlsunset = {
    enable = true;
    latitude = "53.6";
    longitude = "-113.3";
    temperature.day = 6500;
    temperature.night = 3500;
  };

  # USB auto-mounting with tray icon
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
  };

  # Kanshi - automatic display configuration
  services.kanshi = {
    enable = true;
    systemdTarget = "sway-session.target";
    settings = [
      {
        profile.name = "laptop-only";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
        ];
      }
      {
        profile.name = "external-only";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "*";
            status = "enable";
          }
        ];
      }
    ];
  };

  # gnome-keyring for secrets (WiFi passwords, etc.)
  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" ];
  };

  # Packages
  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
    brightnessctl
    networkmanagerapplet
    blueman
    libnotify
  ];
}
