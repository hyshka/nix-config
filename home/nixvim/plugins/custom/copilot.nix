# Ref:
# - https://github.com/CopilotC-Nvim/CopilotChat.nvim
# - https://nix-community.github.io/nixvim/search/?query=plugins.copilot-chat
{...}: {
  programs.nixvim = {
    plugins.copilot-lua = {
      enable = true;
      suggestion = {
        autoTrigger = true;
        keymap.accept = "<Right>";
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
      };
    };

    # Ref: https://github.com/CopilotC-Nvim/CopilotChat.nvim?tab=readme-ov-file#tips
    keymaps = [
      {
        mode = "n";
        key = "<leader>cch";
        action = {
          __raw = ''
            function()
              local actions = require("CopilotChat.actions")
              require("CopilotChat.integrations.telescope").pick(actions.help_actions())
            end
          '';
        };
        options = {
          desc = "[C]opilot[C]hat: [H]elp actions";
        };
      }
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
    ];
  };
}
