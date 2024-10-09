{pkgs, ...}: {
  # TODO: desktop home manager stuff
  home.packages = with pkgs; [
    firefox-devedition-bin
    discord
    slack
    imv
    jellyfin-media-player
    libreoffice
    zathura
    unstable.mullvad-vpn
    spotify
  ];

  home.sessionVariables = {
    TERMINAL = "alacritty";
    BROWSER = "firefox-devedition";
  };
}
