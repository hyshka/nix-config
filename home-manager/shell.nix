
{ inputs, lib, config, pkgs, ... }: {
  home.packages = with pkgs; [
    # utils
    ncdu ranger htop
  ];

  programs.neovim = {
    enable = true;
    vimAlias = true;
  };

  programs.tmux = {
    enable = true;
    tmuxp.enable = true;
    keyMode = "vi";
    terminal = "tmux-256color";
    customPaneNavigationAndResize = true;
    shortcut = "Space";
    baseIndex = 1;
    aggressiveResize = true;
    escapeTime = 10;
    disableConfirmationPrompt = true;
    reverseSplit = true;
    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.sessionist
      tmuxPlugins.pain-control
      tmuxPlugins.prefix-highlight
      tmuxPlugins.fzf-tmux-url
      tmuxPlugins.copycat
      tmuxPlugins.yank
    ];
    extraConfig = ''
      # Switch between last used window
      bind-key C-a last-window
      # Synchronize mode, send same command to all panes
      # I hate the default map
      bind a set-window-option synchronize-panes
      # Make copy mode like visual mode in vim
      bind Escape copy-mode
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'Space' send -X halfpage-down
      bind-key -T copy-mode-vi 'BSpace' send -X halfpage-up
      # 24 bit color
      set-option -sa terminal-features ',xterm-kitty:RGB'
      # statusline
      set -g status-left '#{prefix_highlight}'
      set -g status-right '#{?pane_synchronized, #[bg=blue]#[fg=white] SYNCHRONIZED #[default],} #S '
      # window status
      setw -g window-status-format " #F#I:#W#F "
      setw -g window-status-current-format " #F#I:#W#F "
    '';
  };

  programs.zsh = {
    enable = true;
    autocd = true;
    defaultKeymap = "viins";
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    history = {
      ignoreDups = true;
      expireDuplicatesFirst = true;
    };
    sessionVariables = {
      # zsh-users config
      ZSH_AUTOSUGGEST_USE_ASYNC = 1;
      ZSH_HIGHLIGHT_HIGHLIGHTERS = [ "main" "brackets" "cursor" ];
    };
    # TODO ZIMFW
    #initExtraBeforeCompInit = ''
    #  # zimfw config
    #  zstyle ':zim:input' double-dot-expand yes
    #'';
    #plugins = [
    #  {
    #    name = "zim-completion";
    #    src = pkgs.fetchFromGitHub {
    #      owner = "zimfw";
    #      repo = "completion";
    #      rev = "master";
    #      sha256 = "859b41f4194e8f32aea023383744075f507c6eb0c8d50400efe1b69f33fdccb1";
    #    };
    #    file = "init.zsh";
    #  }
    #  {
    #    src = zsh-completions;
    #    name = "zsh-completions";
    #  }
    #  {
    #    src = zsh-syntax-highlighting;
    #    name = "zsh-syntax-highlighting";
    #  }
    #  # Should be the last one
    #  {
    #    src = zsh-history-substring-search;
    #    name = "zsh-history-substring-search";
    #  }
    #];
  };

  programs.git = {
    enable = true;
    userName = "hyshka";
    userEmail = "bryan@hyshka.com";
  };
}
