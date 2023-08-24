# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ pkgs, ... }:
{
  # Import other home-manager modules in flake.nix
  imports = [
    # You can also split up your configuration and import pieces of it here:
    ../../home-manager/cli
    ../../home-manager/nvim
    # TODO can't launch alacritty via spotlight
    ../../home-manager/alacritty.nix
    # TODO move zimfw module to flake.nix
    ../../modules/home-manager/zimfw.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      #outputs.overlays.additions
      #outputs.overlays.modifications
      #outputs.overlays.unstable-packages

      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    # TODO I don't know why this also needs to be set for home-manager
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

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
