{
  programs.nixvim = {
    # Useful plugin to show you pending keybinds.
    # https://nix-community.github.io/nixvim/plugins/which-key/index.html
    plugins.which-key = {
      enable = true;

      # Document existing key chains
      settings = {
        spec = [
          {
            __unkeyed-1 = "<leader>c";
            group = "[C]ode";
          }
          {
            __unkeyed-1 = "<leader>d";
            group = "[D]ocument";
          }
          {
            __unkeyed-1 = "<leader>r";
            group = "[R]ename";
          }
          {
            __unkeyed-1 = "<leader>s";
            group = "[S]earch";
          }
          {
            __unkeyed-1 = "<leader>w";
            group = "[W]orkspace";
          }
          {
            __unkeyed-1 = "<leader>t";
            group = "[T]oggle";
          }
          {
            __unkeyed-1 = "<leader>h";
            group = "Git [H]unk";
            mode = [
              "n"
              "v"
            ];
          }
        ];
      };

      # TODO: Fix conflicting keymaps
      #WhichKey: checking conflicting keymaps
      #WARNING conflicting keymap exists for mode **"n"**, lhs: **"sh"**
      #rhs: `
      #WARNING conflicting keymap exists for mode **"n"**, lhs: **"sf"**
      #rhs: `
      #WARNING conflicting keymap exists for mode **"n"**, lhs: **"sd"**
      #rhs: `
      #WARNING conflicting keymap exists for mode **"n"**, lhs: **"sr"**
      #rhs: `
      #WARNING conflicting keymap exists for mode **"n"**, lhs: **"sF"**
      # rhs: `
      #WARNING conflicting keymap exists for mode **"n"**, lhs: **" s"**
      # rhs: <Cmd>Telescope oldfiles<CR>
    };
  };
}
