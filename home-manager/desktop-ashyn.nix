{pkgs, ...}: {
  # TODO: desktop home manager stuff
  home.packages = with pkgs; [
    #firefox-devedition-bin
    discord
    # https://nixos.wiki/wiki/Discord#Screensharing_with_audio_on_wayland
    vesktop
    slack
    imv
    jellyfin-media-player
    libreoffice-qt
    zathura
    unstable.mullvad-vpn
    spotify
  ];

  home.sessionVariables = {
    TERMINAL = "alacritty";
    BROWSER = "firefox-devedition";
  };
}
