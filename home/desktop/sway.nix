{
  config,
  pkgs,
  ...
}: {
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
      # TODO export XDG_SESSION_DESKTOP="''${XDG_SESSION_DESKTOP:-sway}"
    '';
    extraConfig = ''
      # https://github.com/flameshot-org/flameshot/blob/master/docs/Sway%20and%20wlroots%20support.md#basic-steps
      exec systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK
      exec hash dbus-update-activation-environment 2>/dev/null && \
        dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK

      # create virtual output on boot for sunshine host
      exec swaymsg create_output HEADLESS-1
      exec swaymsg output HEADLESS-1 resolution 1280x720
    '';
    config = {
      modifier = "Mod4";
      menu = "wofi --show run";
      bars = [
        {
          command = "waybar";
        }
      ];
      #assigns = {
      #  "1" = [{ class = "^Slack$"; }];
      #  "2" = [];
      #  "3" = [{ class = "^Spotify$"; }];
      #  "4" = [{ app_id = "^firefox-aurora$"; } { class = "^Chromium-browser"; }];
      #  "5" = [];
      #};
      #window.commands = [
      #  # generic X11 dialogs
      #  {
      #    command = "floating enable";
      #    criteria = {
      #      window_type = "dialog";
      #      window_role = "dialog";
      #    };
      #  }
      #  # For pop up notification windows that don't use notifications api
      #  {
      #    command = "border none, floating enable";
      #    criteria = {
      #      title = "^zoom$";
      #    };
      #  }
      #  # For specific Zoom windows
      #  {
      #    command = "border pixel, floating enable";
      #    criteria = {
      #      title = "^(Zoom|About)$";
      #    };
      #  }
      #  {
      #    command = "floating enable, floating_minimum_size 960 x 700";
      #    criteria = {
      #      title = "Settings";
      #    };
      #  }
      #  # Open Zoom Meeting windows on a new workspace (a bit hacky)
      #  {
      #    # this just sends it to workspace 1
      #    command = "workspace next_on_output --create, move container to workspace current, floating disable, inhibit_idle open";
      #    criteria = {
      #      title = "Zoom Meeting(.*)?";
      #    };
      #  }
      #];
      output.Headless-1 = {
        mode = "1280x720";
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
}
