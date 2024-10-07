{pkgs, ...}: {
  # https://github.com/JMartJonesy/kickstart.nixvim/blob/main/nixvim.nix
  # https://nix-community.github.io/nixvim/search/
  # https://github.com/nix-community/nixvim/blob/nixos-24.05/
  # https://nix-community.github.io/nixvim/user-guide/config-examples.html
  imports = [
    # Plugins
    ./plugins/gitsigns.nix
    ./plugins/which-key.nix
    ./plugins/telescope.nix
    ./plugins/conform.nix
    ./plugins/lsp.nix
    ./plugins/nvim-cmp.nix
    ./plugins/mini.nix
    ./plugins/treesitter.nix

    # Extra
    ./plugins/kickstart/indent-blankline.nix
    #./plugins/kickstart/lint.nix
    ./plugins/custom/rnvimr.nix
    ./plugins/custom/orgmode.nix
    # TODO
    #./plugins/custom/copilot.nix
  ];

  programs.nixvim = {
    enable = true;
    package = pkgs.unstable.neovim-unwrapped;
    defaultEditor = true;
    vimAlias = true;

    # https://github.com/nix-community/nixvim?tab=readme-ov-file#colorschemes
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "frappe";
        # https://github.com/catppuccin/nvim?tab=readme-ov-file#integrations
        integrations = {
          indent_blankline = {
            enabled = true;
            colored_indent_levels = false;
          };
          gitsigns = true;
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
          mini.enabled = true;
          treesitter = true;
          #treesitter_context = true;
          #rainbow_delimiters = true;
          telescope.enabled = true;
          lsp_trouble = true;
          which_key = true;
        };
      };
    };

    # https://nix-community.github.io/nixvim/NeovimOptions/index.html?highlight=globals#globals
    globals = {
      # Set <space> as the leader key
      # See `:help mapleader`
      mapleader = " ";
      maplocalleader = " ";
    };

    # [[ Setting options ]]
    # See `:help vim.opt`
    # NOTE: You can change these options as you wish!
    #  For more options, you can see `:help option-list`
    # https://nix-community.github.io/nixvim/NeovimOptions/index.html?highlight=globals#opts
    opts = {
      # Show line numbers
      number = true;
      # You can also add relative line numbers, to help with jumping.
      relativenumber = true;

      # Enable mouse mode, can be useful for resizing splits for example!
      mouse = "a";

      # Don't show the mode, since it's already in the statusline
      showmode = false;

      #  See `:help 'clipboard'`
      clipboard = {
        providers = {
          wl-copy.enable = true; # For Wayland
          xsel.enable = true; # For X11
        };

        # Sync clipboard between OS and Neovim
        #  Remove this option if you want your OS clipboard to remain independent.
        register = "unnamedplus";
      };

      # Enable break indent
      breakindent = true;

      # Save undo history
      undofile = true;

      # Case-insensitive searching UNLESS \C or one or more capital letters in search term
      ignorecase = true;
      smartcase = true;

      # Keep signcolumn on by default
      signcolumn = "yes";

      # Decrease update time
      updatetime = 250;

      # Decrease mapped sequence wait time
      # Displays which-key popup sooner
      timeoutlen = 300;

      # Configure how new splits should be opened
      splitright = true;
      splitbelow = true;

      # Sets how neovim will display certain whitespace characters in the editor
      #  See `:help 'list'`
      #  See `:help 'listchars'`
      list = true;
      # NOTE: .__raw here means that this field is raw lua code
      listchars.__raw = "{ tab = '» ', trail = '·', nbsp = '␣' }";

      # Preview subsitutions live, as you type!
      inccommand = "split";

      # Show which line your cursor is on
      cursorline = true;

      # Minimal number of screen lines to keep above and below the cursor
      #scrolloff = 10;

      # See `:help hlsearch`
      hlsearch = true;

      # TODO
      #autoindent = true;
      #expandtab = true;
      #smartindent = true;
      #incsearch = true;
      #wildmode = "list:longest";
      #termguicolors = true;
    };

    # [[ Basic Keymaps ]]
    #  See `:help vim.keymap.set()`
    # https://nix-community.github.io/nixvim/keymaps/index.html
    keymaps = [
      # Clear highlights on search when pressing <Esc> in normal mode
      {
        mode = "n";
        key = "<Esc>";
        action = "<cmd>nohlsearch<CR>";
      }
      # Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
      # for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
      # is not what someone will guess without a bit more experience.
      #
      # NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
      # or just use <C-\><C-n> to exit terminal mode
      {
        mode = "t";
        key = "<Esc><Esc>";
        action = "<C-\\><C-n>";
        options = {
          desc = "Exit terminal mode";
        };
      }
      # Keybinds to make split navigation easier.
      #  Use CTRL+<hjkl> to switch between windows
      #
      #  See `:help wincmd` for a list of all window commands
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w><C-h>";
        options = {
          desc = "Move focus to the left window";
        };
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w><C-l>";
        options = {
          desc = "Move focus to the right window";
        };
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w><C-j>";
        options = {
          desc = "Move focus to the lower window";
        };
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w><C-k>";
        options = {
          desc = "Move focus to the upper window";
        };
      }
    ];

    # https://nix-community.github.io/nixvim/NeovimOptions/autoGroups/index.html
    autoGroups = {
      kickstart-highlight-yank = {
        clear = true;
      };
    };

    # [[ Basic Autocommands ]]
    #  See `:help lua-guide-autocommands`
    # https://nix-community.github.io/nixvim/NeovimOptions/autoCmd/index.html
    autoCmd = [
      # Highlight when yanking (copying) text
      #  Try it with `yap` in normal mode
      #  See `:help vim.highlight.on_yank()`
      {
        event = ["TextYankPost"];
        desc = "Highlight when yanking (copying) text";
        group = "kickstart-highlight-yank";
        callback.__raw = ''
          function()
            vim.highlight.on_yank()
          end
        '';
      }
    ];

    plugins = {
      # Adds icons for plugins to utilize in ui
      web-devicons.enable = true;

      # Detect tabstop and shiftwidth automatically
      # https://nix-community.github.io/nixvim/plugins/sleuth/index.html
      sleuth = {
        enable = true;
      };

      # Highlight todo, notes, etc in comments
      # https://nix-community.github.io/nixvim/plugins/todo-comments/index.html
      todo-comments = {
        enable = true;
        settings = {
          signs = true;
        };
      };
    };

    # The line beneath this is called `modeline`. See `:help modeline`
    # https://nix-community.github.io/nixvim/NeovimOptions/index.html?highlight=extraplugins#extraconfigluapost
    extraConfigLuaPost = ''
      -- vim: ts=2 sts=2 sw=2 et
    '';

    # TODO: REVIEW MY STUFF
    #plugins.lightline = {
    #  enable = true;
    #  colorscheme = "catppuccin";
    #  active = {
    #    right = [
    #      [
    #        "linter_checking"
    #        "linter_errors"
    #        "linter_warnings"
    #        "linter_ok"
    #        "lineinfo"
    #        "percent"
    #        "fileformat"
    #        "fileencoding"
    #        "filetype"
    #      ]
    #    ];
    #  };
    #  component = {filename = "%{expand('%:p:h:t')}/%t";};
    #};

    #plugins.nvim-colorizer.enable = true;

    #plugins = {
    #  treesitter-context = {
    #    enable = true;
    #    settings = {max_lines = 2;};
    #  };
    #  rainbow-delimiters.enable = true;
    #  hmts.enable = true;
    #};

    #plugins = {
    #  copilot-lua = {
    #    enable = true;
    #    suggestion.autoTrigger = true;
    #  };
    #  copilot-chat = {
    #    enable = true;
    #  };
    #};

    #plugins = {
    #  lsp = {
    #    enable = true;
    #    servers = {
    #      tsserver.enable = true;
    #      volar.enable = true;
    #      eslint.enable = true;
    #      pylsp.enable = true; # TODO python 3.10
    #      bashls.enable = true;
    #      jsonls.enable = true;
    #      emmet-ls.enable = true;
    #      html.enable = true;
    #      yamlls.enable = true;
    #      ruff-lsp.enable = true;
    #      nixd.enable = true;
    #    };
    #  };
    #  schemastore.enable = true;
    #  trouble.enable = true;
    #  typescript-tools.enable = true;
    #};

    #plugins.none-ls = {
    #  enable = true;
    #  sources = {
    #    completion = {
    #      tags.enable = true;
    #    };
    #    diagnostics = {
    #      editorconfig_checker.enable = true;
    #      trail_space.enable = true;
    #    };
    #    formatting = {
    #      #blackd.enable = true; # TODO is this needed with ruff-lsp?
    #      prettierd.enable = true;
    #      alejandra.enable = true;
    #      markdownlint.enable = true;
    #    };
    #  };
    #};
  };
}
