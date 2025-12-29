{ pkgs, ... }:
{
  security.polkit.enable = true;
  services.udisks2.enable = true;
  # Screen sharing under wayland
  xdg = {
    portal = {
      enable = true;
      wlr.enable = true;
    };
  };

  # Use greetd instead of getty autologin for proper session management
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
        user = "greeter";
      };
    };
  };

  # swaylock support
  security.pam.services.swaylock = { };

  # gnome-keyring for secrets (WiFi passwords, etc.)
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
}
