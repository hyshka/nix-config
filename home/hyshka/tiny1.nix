{ pkgs, ... }:
{
  imports = [
    ./global
    ../cli
  ];

  home.packages = with pkgs; [
    neovim
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
