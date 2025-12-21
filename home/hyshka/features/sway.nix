{
  config,
  pkgs,
  lib,
  ...
}:
{
  wayland.windowManager.sway = {
    systemd.variables = [ "--all" ];
    enable = true;
    wrapperFeatures.gtk = true;
    config = {
      modifier = "Mod1";
      terminal = "alacritty";
      startup = [
        { command = "brave"; }
      ];
      menu = "wofi --show run";
      bars = [
        {
          command = "waybar";
        }
      ];
      keybindings =
        let
          modifier = config.wayland.windowManager.sway.config.modifier;
        in
        lib.mkOptionDefault {
          # Desktop Utilities
          "${modifier}+c" = "exec ${pkgs.clipman}/bin/clipman pick -t wofi";

          # Main app shortcuts
          "${modifier}+Shift+w" = "exec ${pkgs.brave}/bin/brave";
          "${modifier}+Shift+v" = "exec ${pkgs.pavucontrol}/bin/pavucontrol";
        };
    };
  };
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        height = 30;
        modules-left = [
          "sway/workspaces"
          "sway/mode"
          "sway/scratchpad"
        ];
        modules-center = [ "sway/window" ];
        modules-right = [
          "clock"
          "tray"
        ];
      };
    };
  };
  programs.swaylock.enable = true;
  programs.wofi.enable = true;
  services.swayidle.enable = true;
}
