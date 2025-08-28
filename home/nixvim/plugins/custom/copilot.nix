# Ref:
# - https://github.com/CopilotC-Nvim/CopilotChat.nvim
# - https://nix-community.github.io/nixvim/search/?query=plugins.copilot-chat
{...}: {
  programs.nixvim = {
    plugins.copilot-lua = {
      enable = true;
      settings = {
        panel.enabled = false;
        suggestion.enabled = false;
      };
    };

    plugins.copilot-chat = {
      enable = true;
      settings = {
        mappings = {
          complete = {
            insert = "";
          };
        };
        model = "claude-sonnet-4";
      };
    };

    # Ref: https://github.com/CopilotC-Nvim/CopilotChat.nvim?tab=readme-ov-file#tips
    keymaps = [
      {
        mode = "n";
        key = "<leader>ccp";
        action = {
          __raw = ''
            function()
              local actions = require("CopilotChat.actions")
              require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
            end'';
        };
        options = {
          desc = "[C]opilot[C]hat: [P]rompt actions";
        };
      }
      {
        mode = "n";
        key = "<leader>ccq";
        action = {
          __raw = ''
            function()
              local input = vim.fn.input("Quick Chat: ")
              if input ~= "" then
                require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
              end
            end'';
        };
        options = {
          desc = "[C]opilot[C]hat: [Q]uick chat";
        };
      }
      {
        mode = "n";
        key = "<leader>cct";
        action = "<cmd>CopilotChatToggle<CR>";
        options = {
          desc = "[C]opilot[C]hat: [T]oggle";
        };
      }
    ];
  };
}
