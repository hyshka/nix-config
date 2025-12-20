{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./global
    ./features/alacritty.nix
    ./features/opencode.nix
    ./features/sway.nix

    # TODO
    ../nixvim
    ../cli
    ../desktop/font.nix
  ];

  nixGL.packages = inputs.nixGL.packages;

  home.packages = with pkgs; [
    libreoffice-qt
    mullvad-vpn
    spotify-player
    brave
    incus
  ];
}
