{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    mouse = true;
    keyMode = "vi";
    terminal = "tmux-256color";
    customPaneNavigationAndResize = true;
    shortcut = "Space";
    baseIndex = 1;
    aggressiveResize = true;
    escapeTime = 10;
    disableConfirmationPrompt = true;
    reverseSplit = true;
    tmuxp.enable = true;
    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.sessionist
      tmuxPlugins.pain-control
      tmuxPlugins.prefix-highlight
      tmuxPlugins.fzf-tmux-url
      tmuxPlugins.tmux-fzf
      tmuxPlugins.copycat
      tmuxPlugins.yank
      tmuxPlugins.catppuccin
    ];
    extraConfig = ''
      # Fix shell on macos
      set -g default-command "zsh"
      # Configure theme options
      set -g @catppuccin_flavour "mocha"
      # Customize status line
      set -g status-left ""
      set -g status-right-length 100
      set -g status-right "#{E:@catppuccin_status_session}"
      # Customize window list
      set -g @catppuccin_window_text "#{?#{!=:#W,zsh},#W,#T}"
      set -g @catppuccin_window_current_text "#{?#{!=:#W,zsh},#W,#T}"
      # TODO the following isn't being applied well from upstream
      set -gF window-status-format "#{E:@_ctp_w_number_style}#{E:@catppuccin_window_left_separator}#{@catppuccin_window_number}"
      set -agF window-status-format "#{E:@catppuccin_window_middle_separator}"
      set -agF window-status-format "#{E:@_ctp_w_text_style}#{@catppuccin_window_text}#{@_ctp_w_flags}#{E:@catppuccin_window_right_separator}"
      # Switch between last used window
      bind-key C-Space last-window
      # Synchronize mode, send same command to all panes
      # I hate the default map
      bind a set-window-option synchronize-panes
      # Make copy mode like visual mode in vim
      bind Escape copy-mode
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'Space' send -X halfpage-down
      bind-key -T copy-mode-vi 'BSpace' send -X halfpage-up
      # 24 bit color
      set -as terminal-features ",alacritty*:RGB"
      # Set the display panes timeout
      set-option -g display-panes-time 4000
      # Enable persistent sessions
      set -g @continuum-restore 'on'
      set -g @resurrect-capture-pane-contents 'on'
      # session picker
      bind-key s run-shell -b "${pkgs.tmuxPlugins.tmux-fzf}/share/tmux-plugins/tmux-fzf/scripts/session.sh switch"
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
          - window_name: config
            layout: main-vertical
            options:
              main-pane-width: 50%
            panes:
              - shell_command:
                - cd nix-config; nvim
                focus: true
              - shell_command:
                - cd nix-config; git fetch -a
          - window_name: ai
            layout: main-vertical
            panes:
              - shell_command:
                - cd nix-config
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
        start_directory: "''${HOME}/work/muckrack/code"
        windows:
          - window_name: code
            focus: true
            shell_command_before:
              - git fetch -a
            panes:
              - nvim
          - window_name: web
            layout: main-vertical
            panes:
              - make docker-up
              - blank
              - blank
          - window_name: ai
            shell_command_before:
              - nix shell 'nixpkgs#nodejs_24'
            panes:
              - shell_command:
                - opencode
          - window_name: deploy
            panes:
              - shell_command:
                - cd ..; nix-shell
      '';
      target = "tmuxp/muckrack.yml";
    };
    "tmuxp_worktree" = {
      text = ''
        session_name: "''${SESSION_NAME}"
        start_directory: "''${HOME}/work/muckrack/code"
        shell_command_before:
          - if [ -d ../''${SESSION_NAME} ]; then cd ../''${SESSION_NAME}; else git worktree add ../''${SESSION_NAME} -b ''${BRANCH_NAME} && cd ../''${SESSION_NAME}; fi
        windows:
          - window_name: code
            panes:
              - nvim
          - window_name: web
            layout: main-vertical
            panes:
              - blank
              - blank
          - window_name: ai
            focus: true
            shell_command_before:
              - nix shell 'nixpkgs#nodejs_24'
            panes:
              - shell_command:
                - claude
      '';
      target = "tmuxp/worktree.yml";
    };
  };
}
