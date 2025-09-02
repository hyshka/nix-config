{pkgs, ...}: let
  # https://github.com/CopilotC-Nvim/CopilotChat.nvim/blob/main/lua/CopilotChat/config/prompts.lua#L118
  SYSTEM_REVIEW = ''
    [[You are a code reviewer focused on improving code quality and maintainability.

    Format each issue you find precisely as:
    line=<line_number>: <issue_description>
    OR
    line=<start_line>-<end_line>: <issue_description>

    Check for:
    - Unclear or non-conventional naming
    - Comment quality (missing or unnecessary)
    - Complex expressions needing simplification
    - Deep nesting or complex control flow
    - Inconsistent style or formatting
    - Code duplication or redundancy
    - Potential performance issues
    - Error handling gaps
    - Security concerns
    - Breaking of SOLID principles

    Multiple issues on one line should be separated by semicolons.
    End with: "**`To clear buffer highlights, please ask a different question.`**"

    If no issues found, confirm the code is well-written and explain why.]]
  '';
in {
  programs.nixvim = {
    #extraPlugins = [
    #  pkgs.vimPlugins.vectorcode-nvim
    #];
    #extraPackages = [pkgs.vectorcode];

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
          #vectorcode = {
          #  enabled = true;
          #  opts = {
          #    add_tool = true;
          #    add_slash_command = true;
          #  };
          #};
        };
        prompt_library = {
          "Review" = {
            strategy = "chat";
            description = "Review the selected code";
            opts = {
              modes = ["v"];
              short_name = "review";
              auto_submit = true;
              user_prompt = false;
              stop_context_insertion = true;
            };
            prompts = [
              {
                role = "system";
                content = "${SYSTEM_REVIEW}";
                opts = {
                  visible = false;
                };
              }
              {
                role = "user";
                content.__raw = ''
                  function(context)
                    local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

                    return string.format([[
                      Please review this code from buffer %d:
                      ```%s
                      %s
                      ```
                      ]],
                      context.bufnr,
                      context.filetype,
                      code
                    )
                  end
                '';
                opts = {
                  contains_code = true;
                };
              }
            ];
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
