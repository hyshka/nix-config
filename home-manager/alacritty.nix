{
  config,
  pkgs,
  lib,
  ...
}: let
  isLinux = pkgs.stdenv.isLinux;
in {
  programs.alacritty = {
    enable = true;
    # https://alacritty.org/config-alacritty.html
    settings = {
      window = {
        startup_mode = "Fullscreen";
        option_as_alt = "Both";
      };
      font = {
        size = 14.0;
        normal = lib.mkIf isLinux {
          family = config.fontProfiles.monospace.family;
        };
      };
      scrolling = {
        history = 0;
      };
    };
  };
}
