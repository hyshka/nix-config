{
  lib,
  config,
  ...
}:
{
  programs.nixvim = {
    # Useful status updates for LSP.
    # https://nix-community.github.io/nixvim/plugins/fidget/index.html
    plugins.fidget = {
      enable = true;
    };

    # https://nix-community.github.io/nixvim/plugins/schemastore/index.html
    plugins.schemastore.enable = true;

    # A plugin that properly configures LuaLS for editing your Neovim config
    #  by lazily updating your workspace libraries.
    #  https://nix-community.github.io/nixvim/plugins/lazydev/index.html
    plugins.lazydev = {
      enable = true; # autoEnableSources not enough
      settings = {
        library = [
          {
            path = "\${3rd}/luv/library";
            words = [ "vim%.uv" ];
          }
        ];
      };
    };

    plugins.lspconfig.enable = true;

    # Define @lsp.type.component highlight group for Vue
    highlight."@lsp.type.component".link = "Type";

    lsp = {
      inlayHints.enable = true;
      servers = {
        "*" = {
          config = {
            capabilities = {
              textDocument = {
                semanticTokens = {
                  multilineTokenSupport = true;
                };
              };
            };
            root_markers = [
              ".git"
            ];
          };
        };
        ts_ls.enable = true;
        # TODO: when tsgo stabilizes
        #tsgo.enable = true;
        vue_ls = {
          enable = true;
          # Configure semantic tokens per Vue language tools recommendations
          # https://github.com/vuejs/language-tools/wiki/Neovim
          config.onAttach = ''
            function(client, bufnr)
              if vim.bo.filetype == 'vue' then
                client.server_capabilities.semanticTokensProvider.full = false
              else
                client.server_capabilities.semanticTokensProvider.full = true
              end
            end
          '';
        };
        # https://github.com/jfly/snow/blob/main/packages/neovim/lsp.nix#L41-L71
        ts_ls.config = {
          filetypes = [
            "vue"
            "javascript"
            "javascriptreact"
            "javascript.jsx"
            "typescript"
            "typescriptreact"
            "typescript.tsx"
          ];
          init_options.plugins = [
            {
              name = "@vue/typescript-plugin";
              location = "${lib.getBin config.programs.nixvim.lsp.servers.vue_ls.package}/lib/language-tools/packages/language-server";
              languages = [ "vue" ];
            }
          ];
        };
        pyright.enable = true;
        ruff.enable = true;
        emmet_ls.enable = true;
        gopls.enable = true;
        html.enable = true;
        cssls.enable = true;
        dockerls.enable = true;
        bashls.enable = true;
        marksman.enable = true;
        sqls.enable = true;
        stylelint_lsp.enable = true;

        # https://github.com/fourdigits/django-template-lsp
        #djlsp = {
        #  enable = true;
        #  # TODO: unpackaged pip install django-template-lsp
        #  #package = pkgs.djlsp;
        #  # TODO: specific to MR project
        #  extraOptions.options.djlsp = {
        #    django_settings_module = "muckrack.settings";
        #    docker_compose_file = "docker-compose.yml";
        #    docker_compose_service = "web";
        #  };
        #};

        nil_ls = {
          enable = true;
          config.formatting.command = [ "nixfmt" ];
        };
        jsonls = {
          enable = true;
          config = {
            json = {
              schemas.__raw = "require('schemastore').json.schemas()";
              validate = {
                enable = true;
              };
            };
          };
        };
        yamlls = {
          enable = true;
          config = {
            yaml = {
              schemas.__raw = "require('schemastore').yaml.schemas()";
              schemaStore = {
                enable = false;
                url = "";
              };
            };
          };
        };
        lua_ls = {
          enable = true;
          config = {
            completion = {
              callSnippet = "Replace";
            };
          };
        };
      };
    };

    plugins.lsp.keymaps = {
      diagnostic = {
        "<leader>q" = {
          mode = "n";
          action = "setloclist";
          desc = "Open diagnostic [Q]uickfix list";
        };
      };

      extra = [
        # Find references for the word under your cursor.
        {
          mode = "n";
          key = "grr";
          action.__raw = "require('telescope.builtin').lsp_references";
          options = {
            desc = "LSP: [G]oto [R]eferences";
          };
        }
        # Jump to the implementation of the word under your cursor.
        #  Useful when your language has ways of declaring types without an actual implementation.
        {
          mode = "n";
          key = "gri";
          action.__raw = "require('telescope.builtin').lsp_implementations";
          options = {
            desc = "LSP: [G]oto [I]mplementation";
          };
        }
        # Jump to the definition of the word under your cursor.
        #  This is where a variable was first declared, or where a function is defined, etc.
        #  To jump back, press <C-t>.
        {
          mode = "n";
          key = "grd";
          action.__raw = "require('telescope.builtin').lsp_definitions";
          options = {
            desc = "LSP: [G]oto [D]efinition";
          };
        }
        # Fuzzy find all the symbols in your current document.
        #  Symbols are things like variables, functions, types, etc.
        {
          mode = "n";
          key = "gO";
          action.__raw = "require('telescope.builtin').lsp_document_symbols";
          options = {
            desc = "LSP: Open Document Symbols";
          };
        }
        # Fuzzy find all the symbols in your current workspace.
        #  Similar to document symbols, except searches over your entire project.
        {
          mode = "n";
          key = "gW";
          action.__raw = "require('telescope.builtin').lsp_dynamic_workspace_symbols";
          options = {
            desc = "LSP: Open Workspace Symbols";
          };
        }
        # Jump to the type of the word under your cursor.
        #  Useful when you're not sure what type a variable is and you want to see
        #  the definition of its *type*, not where it was *defined*.
        {
          mode = "n";
          key = "grt";
          action.__raw = "require('telescope.builtin').lsp_type_definitions";
          options = {
            desc = "LSP: [G]oto [T]ype Definition";
          };
        }
      ];

      lspBuf = {
        # Rename the variable under your cursor.
        #  Most Language Servers support renaming across files, etc.
        "grn" = {
          action = "rename";
          desc = "LSP: [R]e[n]ame";
        };
        # Execute a code action, usually your cursor needs to be on top of an error
        # or a suggestion from your LSP for this to activate.
        "gra" = {
          mode = [
            "n"
            "x"
          ];
          action = "code_action";
          desc = "LSP: [G]oto Code [A]ction";
        };
        # WARN: This is not Goto Definition, this is Goto Declaration.
        #  For example, in C this would take you to the header.
        "grD" = {
          action = "declaration";
          desc = "LSP: [G]oto [D]eclaration";
        };
      };
    };
  };
}
