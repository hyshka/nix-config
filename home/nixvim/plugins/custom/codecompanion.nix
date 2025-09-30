{pkgs, ...}: let
  SYSTEM_REVIEW = ''
    [[Your task is to review the provided code snippet, focusing specifically on its readability and maintainability.
    Identify any issues related to:
    - Naming conventions that are unclear, misleading or doesn't follow conventions for the language being used.
    - The presence of unnecessary comments, or the lack of necessary ones.
    - Overly complex expressions that could benefit from simplification.
    - High nesting levels that make the code difficult to follow.
    - The use of excessively long names for variables or functions.
    - Any inconsistencies in naming, formatting, or overall coding style.
    - Repetitive code patterns that could be more efficiently handled through abstraction or optimization.

    Your feedback must be concise, directly addressing each identified issue with:
    - A clear description of the problem.
    - A concrete suggestion for how to improve or correct the issue.

    Format your feedback as follows:
    - Explain the high-level issue or problem briefly.
    - Provide a specific suggestion for improvement.

    If the code snippet has no readability issues, simply confirm that the code is clear and well-written as is.
    ]]
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
            description = "Review the selected code in a buffer and suggest improvements.";
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
                      Please review this code from buffer %d and provide suggestions for improvement then refactor the following code to improve its clarity and readability.

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
          "Generate a Commit Message" = {
            strategy = "chat";
            description = "Generate a commit message";
            opts = {
              is_slash_cmd = true;
              short_name = "commit";
              auto_submit = true;
            };
            prompts = [
              {
                role = "user";
                content.__raw = ''
                  function()
                    return string.format(
                      [[You are an expert at following the Conventional Commit specification. Given the git diff listed below, please generate a commit message for me. If the branch name contains "sc-" with a number following it, include that tag on a separately line at the bottom of the commit message. E.g. "Issue: [sc-12345]"

```diff
%s
```
]],
                      vim.fn.system("git diff --no-ext-diff --staged")
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
