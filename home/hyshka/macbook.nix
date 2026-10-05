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
    curl
    amazon-ecr-credential-helper # pulling docker images from ECR
    ssm-session-manager-plugin # optional
    mysql84 # for make setup-local-dev
  ];

  programs.uv = {
    enable = true;
    python = {
      default = [ "3.13" ];
      versions = [
        "3.12"
        "3.13"
        "3.14"
      ];
      prune = true;
    };
  };

  programs.awscli = {
    enable = true;
  };

  programs.granted = {
    enable = true;
    enableZshIntegration = true;
  };

  home.sessionVariables = {
    MUCKRACK_HOME = "/Users/hyshka/Work/muckrack/code";
  };
}
