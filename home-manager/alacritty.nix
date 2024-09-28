{
  config,
  pkgs,
  ...
}: {
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
        normal = {
          family = config.fontProfiles.monospace.family;
        };
      };
      import = [
        "${pkgs.catppuccin-alacritty}/catppuccin-frappe.toml"
      ];
      scrolling = {
        history = 0;
      };
    };
  };
}
