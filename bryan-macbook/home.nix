# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, outputs, lib, config, pkgs, ... }:
{
  # You can import other home-manager modules here
  imports = [
    # You can also split up your configuration and import pieces of it here:
    ../home-manager/cli
    ../home-manager/nvim
    # TODO move zimfw module to flake.nix
    ../modules/home-manager/zimfw.nix
  ];

  home = {
    username = "hyshka";
    homeDirectory = "/Users/hyshka";
  };

  # TODO move to module
  sops = {
    gnupg = {
      home = "/Users/hyshka/.gnupg";
    };
    defaultSopsFile = ../home-manager/secrets.yaml;
    secrets = {
      # TODO move to cli/zsh.nix?
      mr_gemfury_deploy_token = {
        path = "%r/mr_gemfury_deploy_token.txt";
      };
      mr_pip_extra_index_url = {
        path = "%r/mr_pip_extra_index_url.txt";
      };
      mr_fontawesome_npm_auth_token = {
        path = "%r/mr_fontawesome_npm_auth_token.txt";
      };
    };
  };

  # TODO can't launch alacritty via spotlight
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
