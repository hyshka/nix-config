{ pkgs, ... }: {
  programs.neovim = {
    extraPackages = with pkgs; [
      black
      nodePackages.eslint_d
      nodePackages.prettier
      nodePackages.typescript-language-server
      python311Packages.python-lsp-ruff
      nodePackages.pyright
      nodePackages.vscode-langservers-extracted
      nodePackages.yaml-language-server
      nil
    ];

    plugins = with pkgs.vimPlugins; [
      # LSP
      # Ref: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
      # Required packages
      # typescript: typescript-language-server
      # python: ruff-lsp, pyright
      # json: vscode-langservers-extracted
      # yaml: yaml-language-server
      # nix: nil
      SchemaStore-nvim
      {
        plugin = trouble-nvim;
        type = "lua";
        config = /* lua */ ''
          local trouble = require('trouble')
	  -- settings without a patched font or icons
          trouble.setup({
	    icons = false,
	    fold_open = "v", -- icon used for open folds
	    fold_closed = ">", -- icon used for closed folds
	    indent_lines = false, -- add an indent guide below the fold icons
	    signs = {
	      -- icons / text used for a diagnostic
	      error = "error",
	      warning = "warn",
	      hint = "hint",
	      information = "info"
	    },
	    use_diagnostic_signs = false -- enabling this will use the signs defined in your lsp client
	  })

	  vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>",
            {silent = true, noremap = true}
          )
          vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>",
            {silent = true, noremap = true}
          )
          vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>",
            {silent = true, noremap = true}
          )
          vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>",
            {silent = true, noremap = true}
          )
          vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>",
            {silent = true, noremap = true}
          )
          vim.keymap.set("n", "gR", "<cmd>TroubleToggle lsp_references<cr>",
            {silent = true, noremap = true}
          )
	'';
      }
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = /* lua */ ''
          local lspconfig = require('lspconfig')

          function add_lsp(binary, server, options)
            if vim.fn.executable(binary) == 1 then server.setup(options) end
          end

          add_lsp("pyright", lspconfig.pyright, {})
          add_lsp("tsserver", lspconfig.tsserver, {
	    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx", "vue"}
	  })
          add_lsp("ruff_lsp", lspconfig.ruff_lsp, {})
          add_lsp("nil_ls", lspconfig.nil_ls, {})
          add_lsp("jsonls", lspconfig.jsonls, {
            settings = {
              json = {
                schemas = require('schemastore').json.schemas(),
                validate = { enable = true },
              },
            },
          })
          add_lsp("yamlls", lspconfig.yamlls, {
            settings = {
              yaml = {
                schemas = require('schemastore').yaml.schemas(),
              },
            },
          })
          --add_lsp("docker-langserver", lspconfig.dockerls, {})
          --add_lsp("bash-language-server", lspconfig.bashls, {})
          --add_lsp("pylsp", lspconfig.pylsp, {})
          --add_lsp("ltex-ls", lspconfig.ltex, {})

          -- Global mappings.
          -- See `:help vim.diagnostic.*` for documentation on any of the below functions
          vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
          vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

          -- Use LspAttach autocommand to only map the following keys
          -- after the language server attaches to the current buffer
          vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('UserLspConfig', {}),
            callback = function(ev)
              -- Enable completion triggered by <c-x><c-o>
              vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

              -- Buffer local mappings.
              -- See `:help vim.lsp.*` for documentation on any of the below functions
              local opts = { buffer = ev.buf }
              vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
              vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
              vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
              vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
              vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
              vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
              vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
              vim.keymap.set('n', '<space>wl', function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
              end, opts)
              vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
              vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
              vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
              vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
              vim.keymap.set('n', '<space>f', function()
                vim.lsp.buf.format { async = true }
              end, opts)
            end,
          })
        '';
      }
      {
        plugin = null-ls-nvim;
        type = "lua";
        config = /* lua */ ''
          -- null-ls: eslint, black, semgrep, sqlfluff
          -- Ref: https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
          -- mypy requires: sudo pip install django-stubs django-stubs-ext

          local null_ls = require("null-ls")
          local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

          null_ls.setup({
              debug = true,
              sources = {
                  null_ls.builtins.code_actions.eslint_d,
                  null_ls.builtins.completion.tags,
                  null_ls.builtins.diagnostics.eslint_d,
          	--TODO mypy requires all project dependencies to be installed
          	--null_ls.builtins.diagnostics.mypy,
                  --null_ls.builtins.diagnostics.semgrep,
                  --null_ls.builtins.diagnostics.sqlfluff.with({
                  --    extra_args = { "--dialect", "mysql" },
                  --}),
                  null_ls.builtins.diagnostics.trail_space,
                  --TODO docformatter
                  null_ls.builtins.formatting.black,
                  null_ls.builtins.formatting.eslint_d,
                  null_ls.builtins.formatting.prettier,
		  --TODO prettierd not in NixOS
                  --null_ls.builtins.formatting.prettierd,
                  null_ls.builtins.formatting.trim_whitespace,
              },
              on_attach = function(client, bufnr)
                  if client.supports_method("textDocument/formatting") then
                      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                      vim.api.nvim_create_autocmd("BufWritePre", {
                          group = augroup,
                          buffer = bufnr,
                          callback = function()
			      --vim.lsp.buf.format({ async = false })
			      vim.lsp.buf.format({
			        async = false,
				bufnr = bufnr,
				filter = function(client)
				    return client.name == "null-ls"
				end
			    })
                          end,
                      })
                  end
              end,
          })
        '';
      }
    ];
  };
}
