{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./global.nix
    ../desktop/alacritty.nix
    ../desktop/sway.nix
    ../ai/opencode.nix
    ../nixvim
    ../cli
    ../desktop/font.nix
  ];

  programs.opencode = {
    package = lib.mkForce inputs.opencode-flake.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
  };

  nixGL.packages = inputs.nixGL.packages;

  home.packages = with pkgs; [
    libreoffice-qt
    brave
    incus
  ];
}
