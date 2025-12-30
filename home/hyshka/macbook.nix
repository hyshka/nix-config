{ pkgs, ... }:
{
  imports = [
    ./global.nix
    ../desktop/aerospace.nix
    ../desktop/alacritty.nix
    ../ai/opencode.nix
    ../ai/claude.nix
    ../nixvim
    ../cli
  ];

  home = {
    homeDirectory = "/Users/hyshka";
  };

  home.packages = with pkgs; [
    # mine
    spotify-player
    # work
    curl
  ];
}
