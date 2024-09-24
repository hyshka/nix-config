{pkgs, ...}: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    rainbow-delimiters-nvim
    hmts-nvim
    {
      plugin = pkgs.unstable.vimPlugins.nvim-treesitter.withAllGrammars;
      type = "lua";
      config =
        /*
        lua
        */
        ''
	  require'nvim-treesitter.configs'.setup {
            highlight = {
              enable = true,
              additional_vim_regex_highlighting = false,
	      -- disable on very large buffers
	      disable = function(lang, bufnr)
                return vim.fn.getfsize(vim.api.nvim_buf_get_name(bufnr)) > 1048576
              end
            },
            incremental_selection = {
              enable = true,
            },
            indent = {
              enable = true
            },
          }
        '';
    }
  ];
}
