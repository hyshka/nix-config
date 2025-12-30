{
  config,
  pkgs,
  ...
}:
let
  isLinux = pkgs.stdenv.isLinux;
  # See: https://nix-community.github.io/home-manager/index.xhtml#sec-usage-gpu-non-nixos
  alacritty =
    if isLinux then
      { package = config.lib.nixGL.wrap pkgs.alacritty; }
    else
      { package = pkgs.alacritty; };
  fontFamily = if isLinux then config.fontProfiles.monospace.family else "IosevkaTerm NFM";
in
{
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
        size = 16.0;
        normal = {
          family = fontFamily;
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
