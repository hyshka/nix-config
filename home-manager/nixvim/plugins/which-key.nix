{
  programs.nixvim = {
    # Useful plugin to show you pending keybinds.
    # https://nix-community.github.io/nixvim/plugins/which-key/index.html
    plugins.which-key = {
      enable = true;

      # TODO: migrate to unstable
      # Document existing key chains
      registrations = {
        "<leader>c" = "[C]ode";
        "<leader>d" = "[D]ocument";
        "<leader>r" = "[R]ename";
        "<leader>s" = "[S]earch";
        "<leader>w" = "[W]orkspace";
        "<leader>t" = "[T]oggle";
        # TODO: normal and visual mode
        "<leader>h" = ["Git [H]unk" {mode = ["n" "v"];}];
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
