{ pkgs, ... }:
{
  programs.nixvim = {
    # Dependencies
    #
    # https://nix-community.github.io/nixvim/NeovimOptions/index.html?highlight=extraplugins#extrapackages
    extraPackages = with pkgs; [
      # Used to format Lua code
      stylua
      alejandra
      ruff
      prettierd
    ];

    # Autoformat
    # https://nix-community.github.io/nixvim/plugins/conform-nvim.html
    plugins.conform-nvim = {
      enable = true;
      settings = {
        notify_on_error = false;
        format_on_save = ''
          function(bufnr)
            -- Disable "format_on_save lsp_fallback" for lanuages that don't
            -- have a well standardized coding style. You can add additional
            -- lanuages here or re-enable it for the disabled ones.
            local disable_filetypes = { c = true, cpp = true }
            local lsp_format_opt
            if disable_filetypes[vim.bo[bufnr].filetype] then
              lsp_format_opt = 'never'
            else
              lsp_format_opt = 'fallback'
            end
            return {
              timeout_ms = 500,
              lsp_format = lsp_format_opt,
            }
          end
        '';
        formatters_by_ft = {
          lua = [ "stylua" ];
          nix = [ "alejandra" ];
          python = [ "ruff" ];
          # html = ["prettierd"];
          javascript = [ "prettierd" ];
          typescript = [ "prettierd" ];
          vue = [ "prettierd" ];
          css = [ "prettierd" ];
          scss = [ "prettierd" ];
        };
      };
    };

    # https://nix-community.github.io/nixvim/keymaps/index.html
    keymaps = [
      {
        mode = "";
        key = "<leader>f";
        action.__raw = ''
          function()
            require('conform').format { async = true, lsp_fallback = true }
          end
        '';
        options = {
          desc = "[F]ormat buffer";
        };
      }
    ];
  };
}
