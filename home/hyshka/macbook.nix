{pkgs, ...}: {
  imports = [
    ./global
    ./features/aerospace.nix
    ./features/alacritty.nix

    # TODO
    ../nixvim
    ../cli
  ];

  home = {
    homeDirectory = "/Users/hyshka";
  };

  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    # mine
    spotify
    # work
    curl
    gimp
    brave
  ];
}
