{pkgs, ...}: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    rainbow-delimiters-nvim
    pkgs.unstable.vimPlugins.hmts-nvim
    # individual grammars
    #(pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [ p.bash p.c p.comment p.cpp p.diff p.devicetree p.dockerfile p.git_config ]))
    pkgs.vimPlugins.nvim-treesitter.withAllGrammars
    {
      plugin = nvim-treesitter;
      type = "lua";
      config =
        /*
        lua
        */
        ''
                 local treesitter = require('nvim-treesitter.configs')
          treesitter.setup({
                   highlight = {
                     enable = true,
                     -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                     -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                     -- Using this option may slow down your editor, and you may see some duplicate highlights.
                     -- Instead of true it can also be a list of languages
                     additional_vim_regex_highlighting = false,
                   },
                   incremental_selection = {
                     enable = true,
                   },
                   indent = {
                     enable = true
                   },
                   rainbow = {
                     enable = true,
                     query = {
                         'rainbow-parens',
                         html = 'rainbow-tags',
                     },
                     strategy = require('ts-rainbow').strategy.global,
                   }
          })
        '';
    }
  ];
}
