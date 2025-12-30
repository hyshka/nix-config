{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./global.nix
    ../desktop/alacritty.nix
    ../desktop/plasma.nix
    ../desktop/zwift.nix
    ../desktop/logseq.nix
    ../ai/opencode.nix
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
    #vkdt # TODO: fix
    darktable
    hugin
    inkscape-with-extensions
    #gimp-with-plugins # TODO: build failed
    mpv
    handbrake
    delfin
    jellyflix
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
    incus
    brave
    solaar
  ];
}
