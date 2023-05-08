# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  home = {
    username = "hyshka";
    homeDirectory = "/home/hyshka";
  };

  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    # utils
    ncdu ranger htop

    # fonts
    iosevka-bin
  ];

  programs.neovim = {
    enable = true;
    vimAlias = true;
  };

  #programs.kitty = {
  #  enable = true;
  #  font = {
  #    size = 11;
  #  };
  #};

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
    plugins = [
      {
        name = "zim-completion";
        src = pkgs.fetchFromGitHub {
	  owner = "zimfw";
	  repo = "completion";
	};
        file = "init.zsh";
      }
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
    ];
  };

  programs.git = {
    enable = true;
    userName = "hyshka";
    userEmail = "bryan@hyshka.com";
  };

  # Enable home-manager
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.11";
}
