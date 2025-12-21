{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./global
    ./features/alacritty.nix
    ./features/sway.nix
    ./features/claude.nix

    # TODO
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
