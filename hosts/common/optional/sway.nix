{ ... }:
{
  security.polkit.enable = true;
  # Screen sharing under wayland
  xdg = {
    portal = {
      enable = true;
      wlr.enable = true;
    };
  };
  services.getty = {
    autologinUser = "hyshka";
    autologinOnce = true;
  };
  environment.loginShellInit = ''
    [[ "$(tty)" == /dev/tty1 ]] && sway
  '';
}
