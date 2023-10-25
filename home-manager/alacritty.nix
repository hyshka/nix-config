{config, ...}: {
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        startup_mode = "Fullscreen";
        option_as_alt = "Both";
      };
      font = {
        size = 12.0;
      };
      colors = {
        # https://github.com/aarowill/base16-alacritty/blob/master/colors/base16-gruvbox-light-medium.yml
        primary = {
          background = "#${config.colorScheme.colors.base00}";
          foreground = "#${config.colorScheme.colors.base05}";
          #dim_foreground = "#${config.colorScheme.colors.base05}";
          #bright_foreground = "#${config.colorScheme.colors.base05}";
        };
        cursor = {
          text = "#${config.colorScheme.colors.base00}";
          cursor = "#${config.colorScheme.colors.base05}";
        };
        normal = {
          black = "#${config.colorScheme.colors.base00}";
          red = "#${config.colorScheme.colors.base08}";
          green = "#${config.colorScheme.colors.base0B}";
          yellow = "#${config.colorScheme.colors.base0A}";
          blue = "#${config.colorScheme.colors.base0D}";
          magenta = "#${config.colorScheme.colors.base0E}";
          cyan = "#${config.colorScheme.colors.base0C}";
          white = "#${config.colorScheme.colors.base05}";
        };
        bright = {
          black = "#${config.colorScheme.colors.base03}";
          red = "#${config.colorScheme.colors.base09}";
          green = "#${config.colorScheme.colors.base01}";
          yellow = "#${config.colorScheme.colors.base02}";
          blue = "#${config.colorScheme.colors.base04}";
          magenta = "#${config.colorScheme.colors.base06}";
          cyan = "#${config.colorScheme.colors.base0F}";
          white = "#${config.colorScheme.colors.base07}";
        };

        #search = {
        #  matches = {
        #    foreground = "#${config.colorScheme.colors.base05}";
        #    background = "#${config.colorScheme.colors.base05}";
        #  };
        #  focused_match = {
        #    foreground = "#${config.colorScheme.colors.base05}";
        #    background = "#${config.colorScheme.colors.base05}";
        #  };
        #};
        #hints = {
        #  start = {
        #    foreground = "#${config.colorScheme.colors.base05}";
        #    background = "#${config.colorScheme.colors.base05}";
        #  };
        #  end = {
        #    foreground = "#${config.colorScheme.colors.base05}";
        #    background = "#${config.colorScheme.colors.base05}";
        #  };
        #};
        #line_indicator = {
        #  foreground = "#${config.colorScheme.colors.base05}";
        #  background = "#${config.colorScheme.colors.base05}";
        #};
        #footer_bar = {
        #  foreground = "#${config.colorScheme.colors.base05}";
        #  background = "#${config.colorScheme.colors.base05}";
        #};
        #dim = {
        #  black = "#${config.colorScheme.colors.base05}";
        #  red = "#${config.colorScheme.colors.base05}";
        #  green = "#${config.colorScheme.colors.base05}";
        #  yellow = "#${config.colorScheme.colors.base05}";
        #  blue = "#${config.colorScheme.colors.base05}";
        #  magenta = "#${config.colorScheme.colors.base05}";
        #  cyan = "#${config.colorScheme.colors.base05}";
        #  white = "#${config.colorScheme.colors.base05}";
        #};
      };
    };
  };
}
