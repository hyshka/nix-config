{
  config,
  lib,
  pkgs,
  ...
}:
let
  term = "${config.home.sessionVariables.TERMINAL}";
  mod = "Mod1";
  exec = "exec --no-startup-id";
in
{
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = mod;
      terminal = term;

      fonts = {
        names = [ config.fontProfiles.sans-serif.family ];
        size = 10.0;
      };

      keybindings = lib.mkOptionDefault {
        "${mod}+space" = "${exec} ${pkgs.dmenu}/bin/dmenu_run";
        "${mod}+Shift+s" = "${exec} flameshot gui";
      };

      bars = [
        {
          position = "top";
          statusCommand = "${pkgs.i3status}/bin/i3status";
        }
      ];
    };
  };

  programs.i3status = {
    enable = true;
    enableDefault = false;
    modules = {
      ipv6.enable = false;

      "wireless _first_" = {
        position = 1;
        settings.format_up = "W: %quality %ip";
      };

      "ethernet _first_" = {
        position = 2;
      };

      "disk /" = {
        position = 3;
        settings.format = "%used/%total (%avail)";
      };

      memory = {
        position = 4;
        settings.format = "%used/%total (%free)";
      };

      load.enable = false;

      "tztime local" = {
        position = 5;
        settings.format = "%Y-%m-%d %a %H:%M";
      };
    };
  };
}
