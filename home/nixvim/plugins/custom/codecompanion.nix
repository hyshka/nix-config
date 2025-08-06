{pkgs, ...}: {
  programs.nixvim = {
    extraPlugins = [
      pkgs.vimPlugins.vectorcode-nvim
    ];
    extraPackages = [pkgs.vectorcode];

    plugins.codecompanion = {
      enable = true;
      settings = {
        extensions = {
          mcphub = {
            callback = "mcphub.extensions.codecompanion";
            opts = {
              make_tools = true;
              show_server_tools_in_chat = true;
              add_mcp_prefix_to_tool_names = false;
              show_result_in_chat = true;
              format_tool = null;
              make_vars = true;
              make_slash_commands = true;
            };
          };
          # https://github.com/Davidyz/VectorCode/blob/main/docs/neovim/README.md#olimorriscodecompanionnvim
          vectorcode = {
            enabled = true;
            opts = {
              add_tool = true;
              add_slash_command = true;
            };
          };
        };
      };
    };

    keymaps = [
      {
        mode = ["v" "n"];
        key = "<leader>ca";
        action = "<cmd>CodeCompanionActions<cr>";
        options.desc = "Actions (CodeCompanion)";
      }
      {
        mode = ["v" "n"];
        key = "<leader>a";
        action = "<cmd>CodeCompanionChat Toggle<cr>";
        options.desc = "Chat Toggle (CodeCompanion)";
      }
      {
        mode = ["v"];
        key = "ga";
        action = "<cmd>CodeCompanionChat Add<cr>";
        options.desc = "Add visually selected chat to the current chat buffer (CodeCompanion)";
      }
    ];

    # Expand 'cc' into 'CodeCompanion' in the command line
    extraConfigLua = ''
      vim.cmd([[cab cc CodeCompanion]])
    '';
  };
}
