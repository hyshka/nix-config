{
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    config = {
      modifier = "Mod4";
      terminal = "alacritty";
      startup = [
        { command = "brave"; }
      ];
    };
  };
  wayland.windowManager.sway.systemd.variables = [ "--all" ];

}
