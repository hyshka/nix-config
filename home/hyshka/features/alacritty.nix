{
  config,
  pkgs,
  lib,
  ...
}: let
  isLinux = pkgs.stdenv.isLinux;
  # See: https://nix-community.github.io/home-manager/index.xhtml#sec-usage-gpu-non-nixos
  alacritty =
    if isLinux
    then {package = config.lib.nixGL.wrap pkgs.alacritty;}
    else {package = pkgs.alacritty;};
in {
  programs.alacritty = {
    enable = true;
    package = alacritty.package;
    # https://alacritty.org/config-alacritty.html
    settings = {
      window = {
        startup_mode = "Maximized";
        option_as_alt = "Both";
      };
      font = {
        size = 14.0;
        # TODO: pkgs.nerd-fonts.iosevka-term
        normal = lib.mkIf isLinux {
          family = config.fontProfiles.monospace.family;
        };
      };
      scrolling = {
        history = 0;
      };
      cursor = {
        vi_mode_style = {
          blinking = "On";
        };
      };
    };
  };

  home.sessionVariables = {
    TERMINAL = "alacritty";
    TERM = "alacritty";
  };
}
