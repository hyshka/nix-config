{ pkgs, ... }:
{
  imports = [
    ./global.nix
    ../desktop/aerospace.nix
    ../desktop/alacritty.nix
    ../desktop/espanso.nix
    #../ai/opencode.nix
    ../ai/claude.nix
    ../ai/omp.nix
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
