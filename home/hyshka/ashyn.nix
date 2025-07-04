{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./global
    ./features/alacritty.nix
    ./features/plasma.nix
    ./features/logseq.nix

    # TODO
    ../nixvim
    ../cli
    ../desktop/font.nix
  ];

  nixGL.packages = inputs.nixGL.packages;

  # TODO: desktop home manager stuff
  home.packages = with pkgs; [
    discord
    # https://nixos.wiki/wiki/Discord#Screensharing_with_audio_on_wayland
    vesktop
    slack
    imv
    jellyfin-media-player
    libreoffice-qt
    mullvad-vpn
    spotify
    #deskflow
  ];

  #nixpkgs.config.permittedInsecurePackages = [
  #  "deskflow-1.18.0"
  #];
}
