{pkgs, ...}: {
  programs.nixvim = {
    enable = true;
    vimAlias = true;

    #clipboard.register = 'unnamedplus';

    globals.mapleader = " ";

    # https://github.com/nix-community/nixvim?tab=readme-ov-file#options
    opts = {
      number = true;
      relativenumber = true;
      splitbelow = true;
      splitright = true;

      autoindent = true;
      clipboard = "unnamedplus";
      expandtab = true;
      shiftwidth = 2;
      smartindent = true;
      tabstop = 2;

      ignorecase = true;
      incsearch = true;
      smartcase = true;
      wildmode = "list:longest";

      undofile = true;

      termguicolors = true;
    };

    # https://github.com/nix-community/nixvim?tab=readme-ov-file#colorschemes
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "latte";
        integrations = {
          indent_blankline = {
            enabled = true;
            colored_indent_levels = false;
          };
          native_lsp = {
            enabled = true;
            virtual_text = {
              errors = ["italic"];
              hints = ["italic"];
              warnings = ["italic"];
              information = ["italic"];
              ok = ["italic"];
            };
            underlines = {
              errors = ["underline"];
              hints = ["underline"];
              warnings = ["underline"];
              information = ["underline"];
              ok = ["underline"];
            };
            inlay_hints = {
              background = true;
            };
          };
          treesitter = true;
          treesitter_context = true;
          rainbow_delimiters = true;
          telescope.enabled = true;
          lsp_trouble = true;
          which_key = true;
        };
      };
    };

    #extraConfigLua = '''';
    #extraConfigVim = '''';

    # https://github.com/nix-community/nixvim?tab=readme-ov-file#key-mappings

    # https://github.com/nix-community/nixvim?tab=readme-ov-file#plugins
    plugins.telescope = {
      enable = true;
      keymaps = {
        "<leader>fg" = "live_grep";
        "<C-p>" = {
          action = "git_files";
          options = {
            desc = "Telescope Git Files";
          };
        };
      };
      extensions.fzf-native = {enable = true;};
    };

    plugins.lightline = {
      enable = true;
      colorscheme = "catppuccin";
      active = {
        right = [
          [
            "linter_checking"
            "linter_errors"
            "linter_warnings"
            "linter_ok"
            "lineinfo"
            "percent"
            "fileformat"
            "fileencoding"
            "filetype"
          ]
        ];
      };
      component = {filename = "%{expand('%:p:h:t')}/%t";};
    };

    plugins.which-key.enable = true;
    plugins.indent-blankline.enable = true;
    plugins.nvim-colorizer.enable = true;

    plugins = {
      treesitter = {
        enable = true;
        nixGrammars = true;
        #folding = true;
        indent = true;
        #incrementalSelection.enable = true;
        # TODO: vue files are too slow with tree-sitter highlighting
        disabledLanguages = ["vue"];
      };
      treesitter-context = {
        enable = true;
        settings = {max_lines = 2;};
      };
      rainbow-delimiters.enable = true;
      hmts.enable = true;
    };

    plugins = {
      copilot-lua = {
        enable = true;
        suggestion.autoTrigger = true;
      };
      copilot-chat = {
        enable = true;
      };
    };

    plugins = {
      lsp = {
        enable = true;
        servers = {
          tsserver.enable = true;
          volar.enable = true;
          eslint.enable = true;
          pylsp.enable = true; # TODO python 3.10
          bashls.enable = true;
          jsonls.enable = true;
          emmet-ls.enable = true;
          html.enable = true;
          yamlls.enable = true;
          ruff-lsp.enable = true;
          nixd.enable = true;
        };
        keymaps.lspBuf = {
          "gd" = "definition";
          "gD" = "references";
          "gt" = "type_definition";
          "gi" = "implementation";
          "K" = "hover";
        };
      };
      schemastore.enable = true;
      trouble.enable = true;
      typescript-tools.enable = true;
    };

    plugins.none-ls = {
      enable = true;
      sources = {
        completion = {
          tags.enable = true;
        };
        diagnostics = {
          editorconfig_checker.enable = true;
          trail_space.enable = true;
        };
        formatting = {
          #blackd.enable = true; # TODO is this needed with ruff-lsp?
          prettierd.enable = true;
          alejandra.enable = true;
          markdownlint.enable = true;
        };
      };
    };

    #extraPlugins = with pkgs.vimPlugins; [
    #  vim-nix
    #];
  };
}
