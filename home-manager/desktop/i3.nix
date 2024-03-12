{
  config,
  lib,
  pkgs,
  ...
}: let
  term = "${config.home.sessionVariables.TERMINAL}";
  mod = "Mod4";
  exec = "exec --no-startup-id";
in {
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = mod;
      terminal = term;

      fonts = {
        names = [config.fontProfiles.sans-serif.family];
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
}
