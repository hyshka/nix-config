{ pkgs, ... }: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    # LSP
    # Ref: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
    # Required packages
    # typescript: typescript-language-server
    # python: ruff-lsp, pyright
    # json: vscode-langservers-extracted
    # yaml: yaml-language-server
    # nix: rnix-lsp
    {
      plugin = nvim-lspconfig;
      type = "lua";
      config = /* lua */ ''
        local lspconfig = require('lspconfig')

        function add_lsp(binary, server, options)
          if vim.fn.executable(binary) == 1 then server.setup(options) end
        end

        add_lsp("pyright", lspconfig.pyright, {})
        add_lsp("tsserver", lspconfig.tsserver, {})
        add_lsp("ruff_lsp", lspconfig.ruff_lsp, {})
        add_lsp("rnix", lspconfig.rnix, {})
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
      '';
    }
  ];
}
