{pkgs, ...}: {
  imports = [
    ./global
    ./features/aerospace.nix
    ./features/alacritty.nix
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
    gimp
    brave
  ];
}
