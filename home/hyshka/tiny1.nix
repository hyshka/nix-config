{pkgs, ...}: {
  imports = [
    ./global

    # TODO
    #../nixvim
    ../cli
  ];

  home.packages = with pkgs; [
    neovim
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
