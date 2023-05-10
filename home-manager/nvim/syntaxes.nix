{ pkgs, ... }: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    nvim-ts-rainbow2
    {
      plugin = nvim-treesitter;
      type = "lua";
      config = /* lua */ ''
        local treesitter = require('nvim-treesitter.configs')
	treesitter.setup({
          ensure_installed = {
              "astro",
              "lua",
              "comment",
              "bash",
              "c",
              "cpp",
              "diff",
              "devicetree",
              "dockerfile",
              "git_config",
              "git_rebase",
              "gitattributes",
              "gitcommit",
              "gitignore",
              "graphql",
              "jsdoc",
              "markdown",
              "sql",
              "toml",
              "css",
              "vimdoc",
              "html",
              "htmldjango",
              "javascript",
              "jsdoc",
              "ledger",
              "json",
              "nix",
              "make",
              "python",
              "query",
              "regex",
              "scss",
              "svelte",
              "terraform",
              "todotxt",
              "typescript",
              "tsx",
              "vim",
              "vue",
              "yaml",
          },

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
