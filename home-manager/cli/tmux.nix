{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    tmuxp.enable = true;
    mouse = true;
    keyMode = "vi";
    # TODO install tmux-256color profile on mac
    # https://gist.github.com/bbqtd/a4ac060d6f6b9ea6fe3aabe735aa9d95
    terminal = "screen-256color";
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
      set-option -sa terminal-features ',screen-256color:RGB'
      # statusline
      set -g status-left '#{prefix_highlight}'
      set -g status-right '#{?pane_synchronized, #[bg=blue]#[fg=white] SYNCHRONIZED #[default],} #S '
      # window status
      setw -g window-status-format " #F#I:#W#F "
      setw -g window-status-current-format " #F#I:#W#F "
      # Set the display panes timeout
      set-option -g display-panes-time 4000
    '';
  };
  xdg.configFile = {
    "tmuxp_dashboard" = {
      text = ''
        session_name: "dashboard"
        start_directory: "''${HOME}"
        windows:
          - window_name: live
            layout: even-vertical
            panes:
              - glances
              - focus: true
              - blank
          - window_name: config
            layout: main-vertical
            options:
              main-pane-height: 80%
            panes:
              - shell_command:
                - cd nix-config; nvim
              - shell_command:
                - cd nix-config; git fetch -a
      '';
      target = "tmuxp/dashboard.yml";
    };
    "tmuxp_project" = {
      text = ''
        session_name: "''${PROJECT}"
        start_directory: "''${PROJECT_PATH}"
        windows:
          - window_name: code
            layout: even-vertical
            focus: true
            panes:
              - shell_command:
                - nvim
                focus: true
          - window_name: shell
            layout: even-vertical
            panes:
              - blank
              - blank
              - blank
      '';
      target = "tmuxp/project.yml";
    };
    "tmuxp_muckrack" = {
      text = ''
        session_name: "muckrack"
        start_directory: "''${HOME}/Work/muckrack"
        windows:
          - window_name: code
            layout: main-horizontal
            options:
              main-pane-height: 80%
            focus: true
            panes:
              - shell_command:
                - nvim
                focus: true
              - shell_command:
                - git fetch -a
          - window_name: web
            layout: even-vertical
            panes:
              - blank
              - blank
          - window_name: test
            layout: even-vertical
            panes:
              - blank
              - blank
          - window_name: deploy
            panes:
              - blank
      '';
      target = "tmuxp/muckrack.yml";
    };
  };
}
