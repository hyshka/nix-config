{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./global
    ./features/alacritty.nix
    ./features/zwift.nix

    # TODO
    ../nixvim
    ../cli
    ../desktop/font.nix
    ../desktop/espanso.nix
  ];

  nixGL.packages = inputs.nixGL.packages;

  # TODO: desktop home manager stuff
  home.packages = with pkgs; [
    discord
    vesktop
    slack
    ansel
    #vkdt # TODO: fix
    darktable
    hugin
    inkscape-with-extensions
    gimp-with-plugins
    digikam
    jellyfin-media-player
    mpv
    handbrake
    obs-studio
    libreoffice-qt
    zathura
    mullvad-vpn
    spotify
    #etlegacy # can't install 32 bit version on 64 bit OS for TC:E
    # TODO: yuzu
    #yuzu-mainline
    lutris
    yubikey-manager
    corectrl
  ];

  home.sessionVariables = {
    BROWSER = "firefox-devedition";
  };
}
