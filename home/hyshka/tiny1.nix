{ pkgs, ... }:
{
  imports = [
    ./global.nix
    ../cli
  ];

  home.packages = with pkgs; [
    neovim
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
