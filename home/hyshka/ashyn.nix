{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./global.nix
    ../desktop/alacritty.nix
    ../desktop/sway.nix
    ../ai/claude.nix
    ../nixvim
    ../cli
    ../desktop/font.nix
  ];

  nixGL.packages = inputs.nixGL.packages;

  home.packages = with pkgs; [
    libreoffice-qt
    mullvad-vpn
    brave
    incus
  ];
}
