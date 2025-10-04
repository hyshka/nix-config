{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./global
    ./features/alacritty.nix
    ./features/plasma.nix
    ./features/zwift.nix
    ./features/logseq.nix
    ./features/opencode.nix

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
    #ansel # TODO: fix
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
