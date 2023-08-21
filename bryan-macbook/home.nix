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

  # TODO WIP
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        startup_mode = "Fullscreen";
        option_as_alt = "Both";
      };
      font = {
        size = 12.0;
      };
    };
  };

  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    # muck rack
    # TODO move to module
    pre-commit
    python310Packages.nodeenv # for node.js pre-commit hooks
    #gnumake
    #awscli2
  ];

  # Enable home-manager
  programs = {
    home-manager.enable = true;
    git.enable = true; # always a requirement for home-manager
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
