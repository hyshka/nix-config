{pkgs, ...}: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    lightline-vim
    {
      plugin = which-key-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require('which-key').setup{}
        '';
    }
    {
      plugin = indent-blankline-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require("ibl").setup()
        '';
    }
    {
      plugin = nvim-colorizer-lua;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require('colorizer').setup{}
        '';
    }
  ];
}
