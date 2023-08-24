# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, outputs, lib, config, pkgs, ... }:
{
  # You can import other home-manager modules here
  imports = [
    # You can also split up your configuration and import pieces of it here:
    ../../home-manager/cli
    ../../home-manager/nvim
    # TODO can't launch alacritty via spotlight
    ../../home-manager/alacritty.nix
    # TODO move zimfw module to flake.nix
    ../../modules/home-manager/zimfw.nix
  ];

  home = {
    username = "hyshka";
    homeDirectory = "/Users/hyshka";
  };

  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    # muck rack
    # TODO move to module
    pre-commit
    python310Packages.nodeenv # for node.js pre-commit hooks
    # TODO aws cli
    #awscli2
    # TODO mrcli
  ];

  # Enable home-manager
  programs = {
    home-manager.enable = true;
    git.enable = true; # always a requirement for home-manager
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
