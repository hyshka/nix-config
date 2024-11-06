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
    # See: https://nix-community.github.io/home-manager/index.xhtml#sec-usage-gpu-non-nixos
    package = config.lib.nixGL.wrap pkgs.alacritty;
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
