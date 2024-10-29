{pkgs, ...}: {
  programs.neovim = {
    extraPackages = with pkgs; [
      nodejs_20
    ];
    plugins = with pkgs.vimPlugins; [
      {
        plugin = copilot-lua;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require('copilot').setup({
              suggestion = {
                auto_trigger = true,
              },
              copilot_node_command = '${pkgs.nodejs_20}/bin/node',
            })
          '';
      }
      {
        plugin = CopilotChat-nvim;
        type = "lua";
        # Ref: https://github.com/jellydn/lazy-nvim-ide/blob/main/lua/plugins/extras/copilot-chat.lua
        config = ''
                 require("CopilotChat").setup({
                   show_help = "yes",
                   prompts = {
                     -- Code related prompts
                     Explain = "Please explain how the following code works.",
                     Review = "Please review the following code and provide suggestions for improvement.",
                     Tests = "Please explain how the selected code works, then generate unit tests for it.",
                     Refactor = "Please refactor the following code to improve its clarity and readability.",
                     FixCode = "Please fix the following code to make it work as intended.",
                     BetterNamings = "Please provide better names for the following variables and functions.",
                     Documentation = "Please provide documentation for the following code.",
                     -- Text related prompts
                     Summarize = "Please summarize the following text.",
                     Spelling = "Please correct any grammar and spelling errors in the following text.",
                     Wording = "Please improve the grammar and wording of the following text.",
                     Concise = "Please rewrite the following text to make it more concise.",
                   },
                 })

          -- Show help actions with telescope
                 vim.keymap.set("n", "<space>cch",
                   function()
                     require("CopilotChat.code_actions").show_help_actions()
                   end
          )

                 -- Show prompts actions with telescope
                 vim.keymap.set("n", "<space>ccp",
                   function()
                     require("CopilotChat.code_actions").show_prompt_actions()
                   end
          )
                 vim.keymap.set("x", "<space>ccp", ":lua require('CopilotChat.code_actions').show_prompt_actions(true)<CR>")

                 -- Code related commands
                 vim.keymap.set("n", "<space>cce", "<cmd>CopilotChatExplain<cr>")
                 vim.keymap.set("n", "<space>ccr", "<cmd>CopilotChatReview<cr>")
                 vim.keymap.set("n", "<space>cct", "<cmd>CopilotChatTests<cr>")
                 vim.keymap.set("n", "<space>ccR", "<cmd>CopilotChatRefactor<cr>")
                 vim.keymap.set("n", "<space>ccn", "<cmd>CopilotChatBetterNamings<cr>")

          -- Chat with Copilot in visual mode
                 vim.keymap.set("x", "<space>ccv", ":CopilotChatVisual")
                 vim.keymap.set("x", "<space>ccx", ":CopilotChatInPlace<cr>")

                 -- Custom input for CopilotChat
                 vim.keymap.set("n", "<space>cci", function()
                   local input = vim.fn.input("Ask Copilot: ")
                   if input ~= "" then
                     vim.cmd("CopilotChat " .. input)
                   end
                 end)

          -- Generate commit message based on the git diff
                 vim.keymap.set("n", "<space>ccm", function()
                   local diff = get_git_diff()
                   if diff ~= "" then
                     vim.fn.setreg('"', diff)
                     vim.cmd("CopilotChat Write commit message for the change with commitizen convention.")
                   end
                 end)
                 vim.keymap.set("n", "<space>ccM", function()
                   local diff = get_git_diff(true)
                   if diff ~= "" then
                     vim.fn.setreg('"', diff)
                     vim.cmd("CopilotChat Write commit message for the change with commitizen convention.")
                   end
                 end)

                 -- Quick chat with Copilot
                 vim.keymap.set("n", "<space>ccq", function()
                   local input = vim.fn.input("Quick Chat: ")
                   if input ~= "" then
                     vim.cmd("CopilotChatBuffer " .. input)
                   end
                 end)

                 -- Debug
                 vim.keymap.set("n", "<space>ccd", "<cmd>CopilotChatDebugInfo<cr>")

                 -- Fix the issue with diagnostic
                 vim.keymap.set("n", "<space>ccf", "<cmd>CopilotChatFixDiagnostic<cr>")

                 -- Clear buffer and chat history
                 vim.keymap.set("n", "<space>ccl", "<cmd>CopilotChatReset<cr>")

                 -- Toggle Copilot Chat Vsplit
                 vim.keymap.set("n", "<space>ccv", "<cmd>CopilotChatVsplitToggle<cr>")
        '';
      }
    ];
  };
}
