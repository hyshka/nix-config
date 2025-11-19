{
  inputs,
  ...
}:
{
  imports = [
    inputs.zimfw.homeManagerModules.zimfw
  ];

  # Disable unused shells
  home.shell.enableBashIntegration = false;
  home.shell.enableFishIntegration = false;
  home.shell.enableNushellIntegration = false;

  programs.zsh = {
    enable = true;
    autocd = true;
    defaultKeymap = "viins";
    autosuggestion.enable = false;
    enableCompletion = false;
    syntaxHighlighting.enable = false;
    historySubstringSearch.enable = false;
    history = {
      ignoreDups = true;
      expireDuplicatesFirst = true;
    };
    dirHashes = {
      conf = "$HOME/nix-config";
      work = "$HOME/work";
      down = "$HOME/Downloads";
      media = "/mnt/media";
    };
    localVariables = {
      # zsh-users config
      ZSH_HIGHLIGHT_HIGHLIGHTERS = [
        "main"
        "brackets"
        "cursor"
      ];
    };
    zimfw = {
      enable = true;
      zmodules = [
        "environment"
        "git"
        "input"
        "termtitle"
        "utility"
        "archive"
        "fzf"
        "ssh"
        "exa" # must come after utility
        "duration-info"
        "git-info"
        "asciiship"
        "zsh-users/zsh-completions --fpath src" # is supposed be before completion
        "completion"
        # must come after completion
        "zsh-users/zsh-autosuggestions"
        "zsh-users/zsh-syntax-highlighting"
        "zsh-users/zsh-history-substring-search"
      ];
    };
    initContent = ''
      # zimfw config
      zstyle ':zim:input' double-dot-expand yes

      # termtitle
      zstyle ':zim:termtitle' hooks 'preexec' 'precmd'
      zstyle ':zim:termtitle:preexec' format "''${''${(A)=1}[1]}"
      zstyle ':zim:termtitle:precmd'  format '%1~'

      # functions
      function morning {
          echo 'Calendar'
          echo 'Bullet journal'
          echo 'Email'
          echo 'Typing (optional)'
          echo 'Coffee'
          echo 'Focus time'
          curl -H "Accept: text/plain" https://icanhazdadjoke.com/
      }
      function tpp {
        if [ -z "$1" ]
        then
            print This command requires an argument. Ex. tpd [projectname]
        else
            PROJECT=$1
            PROJECT_PATH=$(find ~/work/*/* -maxdepth 0 -type d -name $PROJECT)
            print $PROJECT $PROJECT_PATH
            PROJECT=$PROJECT PROJECT_PATH=$PROJECT_PATH tmuxp load project
        fi
      }
      function tpw {
        if [ -z "$1" ] || [ -z "$2" ]; then
          print "Usage: tpw <session_name> <branch_name>"
          return 1
        fi

        SESSION_NAME=$1 BRANCH_NAME=$2 tmuxp load worktree
      }
    '';
    shellAliases = {
      t = "tmux";
      tpd = "tmuxp load dashboard";
      tpm = "tmuxp load muckrack";
    };
  };
}
