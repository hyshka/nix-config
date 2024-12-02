{pkgs, ...}: {
  programs.nixvim = {
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "rnvimr";
        src = pkgs.fetchFromGitHub {
          owner = "kevinhwang91";
          repo = "rnvimr";
          rev = "3c41af742a61caf74a9f83fb82b9ed03ef13b880";
          hash = "sha256-VgDIa405G5PrTFQdGLTBINIONtFjYttKP823+m7t1is=";
        };
      })
    ];

    extraPackages = [
      # Ueberzug does not support Mac
      #pkgs.ueberzugpp
      pkgs.ranger
    ];

    # TODO:
    # - edit rifle.conf for ranger

    extraConfigVim = ''
      let g:rnvimr_enable_ex = 0
      let g:rnvimr_enable_picker = 1
    '';

    # TODO: ERROR Pynvim is not found in Python Lib
    extraPython3Packages = p: with p; [pynvim];

    # https://github.com/kevinhwang91/rnvimr?tab=readme-ov-file#minimal-configuration
    keymaps = [
      {
        mode = "n";
        key = "\\";
        action = "<cmd>RnvimrToggle<CR>";
        options = {
          desc = "[R]anger: [T]oggle";
        };
      }
      {
        mode = "t";
        key = "<C-r>";
        action = "<C-\><C-n><cmd>RnvimrResize<CR>";
        options = {
          desc = "[R]anger: [R]esize";
        };
      }
      {
        mode = "t";
        key = "\\";
        action = "<C-\><C-n><cmd>RnvimrToggle<CR>";
        options = {
          desc = "[R]anger: [T]oggle";
        };
      }
    ];
  };
}
