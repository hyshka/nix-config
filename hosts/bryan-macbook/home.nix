# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  outputs,
  pkgs,
  ...
}: {
  # Import other home-manager modules in flake.nix
  imports = [
    # You can also split up your configuration and import pieces of it here:
    ../../home-manager/cli
    ../../home-manager/nixvim
    ../../home-manager/alacritty.nix
    ./aerospace.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      #outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
  };

  home = {
    username = "hyshka";
    homeDirectory = "/Users/hyshka";
  };

  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    # video
    mpv
    mpvScripts.cutter # https://github.com/rushmj/mpv-video-cutter
    mpvScripts.mpv-webm # https://github.com/ekisu/mpv-webm

    # images
    gimp

    # coding
    pre-commit
    python310Packages.nodeenv # for node.js pre-commit hooks
    # TODO aws cli
    #awscli2
    # TODO mrcli
    lorri # statoscope
  ];

  # Enable home-manager
  programs = {
    home-manager.enable = true;
    git.enable = true; # always a requirement for home-manager
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
