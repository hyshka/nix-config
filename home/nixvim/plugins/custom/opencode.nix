{
  programs.nixvim = {
    plugins.snacks = {
      enable = true;
      settings.input.enabled = true;
    };

    opts.autoread = true;

    plugins.opencode = {
      enable = true;
      settings = { };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>ot";
        action.__raw = "function() require('opencode').toggle() end";
        options.desc = "Toggle embedded";
      }
      {
        mode = "n";
        key = "<leader>oA";
        action.__raw = "function() require('opencode').ask() end";
        options.desc = "Ask";
      }
      {
        mode = "n";
        key = "<leader>oa";
        action.__raw = "function() require('opencode').ask('@this: ', { submit = true }) end";
        options.desc = "Ask about this";
      }
      {
        mode = "v";
        key = "<leader>oa";
        action.__raw = "function() require('opencode').ask('@selection: ') end";
        options.desc = "Ask about selection";
      }
      {
        mode = "n";
        key = "<leader>oe";
        action.__raw = "function() require('opencode').prompt('Explain @this and its context') end";
        options.desc = "Explain this code";
      }
      {
        mode = "n";
        key = "<leader>o+";
        action.__raw = "function() require('opencode').prompt('@buffer', { append = true }) end";
        options.desc = "Add buffer to prompt";
      }
      {
        mode = "v";
        key = "<leader>o+";
        action.__raw = "function() require('opencode').prompt('@selection', { append = true }) end";
        options.desc = "Add selection to prompt";
      }
      {
        mode = "n";
        key = "<leader>on";
        action.__raw = "function() require('opencode').command('session_new') end";
        options.desc = "New session";
      }
      {
        mode = "n";
        key = "<S-C-u>";
        action.__raw = "function() require('opencode').command('messages_half_page_up') end";
        options.desc = "Messages half page up";
      }
      {
        mode = "n";
        key = "<S-C-d>";
        action.__raw = "function() require('opencode').command('messages_half_page_down') end";
        options.desc = "Messages half page down";
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>os";
        action.__raw = "function() require('opencode').select() end";
        options.desc = "Select prompt";
      }
    ];
  };
}
