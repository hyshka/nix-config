# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, outputs, lib, config, pkgs, ... }:
{
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    #inputs.zimfw.homeManagerModules.zimfw
    # TODO sops-nix is broken in darwin right now due to isLinux conditional
    #inputs.sops-nix.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    ../home-manager/cli
    ../home-manager/nvim
    ../modules/home-manager/zimfw.nix
  ];# ++ (builtins.attrValues outputs.homeManagerModules);

  home = {
    username = "hyshka";
    homeDirectory = "/Users/hyshka";
  };

  # Add stuff for your user as you see fit:
  #home.packages = with pkgs; [];

  # Enable home-manager
  programs = {
    home-manager.enable = true;
    git.enable = true; # always a requirement for home-manager
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
