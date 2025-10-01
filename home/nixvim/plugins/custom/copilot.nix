# Ref:
# - https://github.com/CopilotC-Nvim/CopilotChat.nvim
# - https://nix-community.github.io/nixvim/search/?query=plugins.copilot-chat
{ ... }:
{
  programs.nixvim = {
    plugins.copilot-lua = {
      enable = true;
      settings = {
        panel.enabled = false;
        suggestion.enabled = false;
      };
    };
  };
}
