{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  isLinux = pkgs.stdenv.isLinux;
in
{
  # https://github.com/JMartJonesy/kickstart.nixvim/blob/main/nixvim.nix
  # https://nix-community.github.io/nixvim/search/
  # https://github.com/nix-community/nixvim/blob/nixos-24.05/
  # https://nix-community.github.io/nixvim/user-guide/config-examples.html
  imports = [
    inputs.nixvim.homeModules.nixvim
    # Plugins
    ./plugins/gitsigns.nix
    ./plugins/which-key.nix
    ./plugins/telescope.nix
    ./plugins/lsp.nix
    ./plugins/conform.nix
    ./plugins/blink-cmp.nix
    ./plugins/todo-comments.nix
    ./plugins/mini.nix
    ./plugins/treesitter.nix

    # Extra
    ./plugins/autopairs.nix
    ./plugins/indent-blankline.nix
    #./plugins/orgmode.nix
    ./plugins/copilot.nix
    ./plugins/oil.nix
    ./plugins/codecompanion.nix
    #./plugins/opencode.nix
  ];

  programs.nixvim = {
    enable = true;
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
              errors = [ "italic" ];
              hints = [ "italic" ];
              warnings = [ "italic" ];
              information = [ "italic" ];
              ok = [ "italic" ];
            };
            underlines = {
              errors = [ "underline" ];
              hints = [ "underline" ];
              warnings = [ "underline" ];
              information = [ "underline" ];
              ok = [ "underline" ];
            };
            inlay_hints = {
              background = true;
            };
          };
          mini.enabled = true;
          treesitter = true;
          treesitter_context = true;
          rainbow_delimiters = true;
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

      # Set to true if you have a Nerd Font installed and selected in the terminal
      enable_nerds_fonts = true;
    };

    #  See `:help 'clipboard'`
    clipboard = {
      providers = {
        wl-copy.enable = lib.mkIf isLinux true; # For Wayland
        xsel.enable = lib.mkIf isLinux true; # For X11
      };

      # Sync clipboard between OS and Neovim
      # Remove this option if you want your OS clipboard to remain independent.
      register = "unnamedplus";
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
      scrolloff = 1;

      # if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
      # instead raise a dialog asking if you wish to save the current file(s)
      # See `:help 'confirm'`
      confirm = true;

      # See `:help hlsearch`
      hlsearch = true;

      # Enables 24-bit RGB color in the |TUI|
      termguicolors = true;

      # TODO
      #expandtab = true;
      #smartindent = true;
      #wildmode = "list:longest";
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
      # Edit previous buffer
      {
        mode = "n";
        key = "<C-e>";
        action = "<cmd>e#<CR>";
        options = {
          desc = "Edit previous buffer";
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
      #  See `:help vim.hl.on_yank()`
      {
        event = [ "TextYankPost" ];
        desc = "Highlight when yanking (copying) text";
        group = "kickstart-highlight-yank";
        callback.__raw = ''
          function()
            vim.hl.on_yank()
          end
        '';
      }
    ];

    diagnostic = {
      settings = {
        severity_sort = true;
        float = {
          border = "rounded";
          source = "if_many";
        };
        underline = {
          severity.__raw = ''vim.diagnostic.severity.ERROR'';
        };
        signs.__raw = ''
          vim.g.enable_nerds_fonts and {
            text = {
              [vim.diagnostic.severity.ERROR] = '󰅚 ',
              [vim.diagnostic.severity.WARN] = '󰀪 ',
              [vim.diagnostic.severity.INFO] = '󰋽 ',
              [vim.diagnostic.severity.HINT] = '󰌶 ',
            },
          } or {}
        '';
        virtual_text = {
          source = "if_many";
          spacing = 2;
          format.__raw = ''
            function(diagnostic)
              local diagnostic_message = {
                [vim.diagnostic.severity.ERROR] = diagnostic.message,
                [vim.diagnostic.severity.WARN] = diagnostic.message,
                [vim.diagnostic.severity.INFO] = diagnostic.message,
                [vim.diagnostic.severity.HINT] = diagnostic.message,
              }
              return diagnostic_message[diagnostic.severity]
            end
          '';
        };
      };
    };

    plugins = {
      # Adds icons for plugins to utilize in ui
      web-devicons.enable = true;

      # Detect tabstop and shiftwidth automatically
      # https://nix-community.github.io/nixvim/plugins/guess-indent/index.html
      guess-indent = {
        enable = true;
      };
    };

    # The line beneath this is called `modeline`. See `:help modeline`
    # https://nix-community.github.io/nixvim/NeovimOptions/index.html?highlight=extraplugins#extraconfigluapost
    extraConfigLuaPost = ''
      -- vim: ts=2 sts=2 sw=2 et
    '';
  };
}
