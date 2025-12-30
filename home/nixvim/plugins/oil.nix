# https://github.com/stevearc/oil.nvim
# https://nix-community.github.io/nixvim/search/?query=plugins.oil&option=plugins.oil.enable&option_scope=0
{
  programs.nixvim = {
    plugins.oil = {
      enable = true;
    };

    keymaps = [
      {
        mode = "n";
        key = "-";
        action = "<CMD>Oil<CR>";
        options = {
          desc = "Open parent directory";
        };
      }
    ];
  };
}
