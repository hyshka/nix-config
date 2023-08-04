{ pkgs, lib, config, ... }: {
  home.packages = with pkgs; [ nix-zsh-completions ];
  programs.zsh = {
    enable = true;
    autocd = true;
    defaultKeymap = "viins";
    enableAutosuggestions = false;
    enableCompletion = false;
    enableSyntaxHighlighting = false;
    historySubstringSearch.enable = false;
    history = {
      ignoreDups = true;
      expireDuplicatesFirst = true;
    };
    dirHashes = {
      conf  = "$HOME/nix-config";
      fin   = "$HOME/finance";
      work  = "$HOME/work";
      down  = "$HOME/Downloads";
      media = "/mnt/media";
    };
    localVariables = {
      # zsh-users config
      ZSH_HIGHLIGHT_HIGHLIGHTERS = [ "main" "brackets" "cursor" ];
      # ZIM_HOME should be better baked into the zimfw module
      ZIM_HOME = "$HOME/.zim";
    };
    zimfw = {
      enable = true;
      zmodules = [
	#"$PATH_TO_LOCAL_MODULE" # path must exist as env var
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
    initExtra = ''
      # zimfw config
      zstyle ':zim:input' double-dot-expand yes

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
      function tpd {
        if [ -z "$1" ]
        then
            print This command requires an argument. Ex. tpd [projectname]
        else
            PROJECT=$1
            PROJECT_PATH=$(find ~/work/*/* -maxdepth 0 -type d -name $PROJECT)
            print $PROJECT $PROJECT_PATH
            PROJECT=$PROJECT PROJECT_PATH=$PROJECT_PATH tmuxp load ~/.config/tmuxp/project.yml
        fi
      }
    '';
    shellAliases = {
      t = "tmux";
      tpw = "tmuxp load ~/.config/tmuxp/dashboard.yml";
      av = "aws-vault exec mr-bryan --";
    };
    sessionVariables = {
      # TODO move to ledger module
      LEDGER_FILE = "~/finance/2023/2023.journal";
    };
    envExtra = ''
      # GemFury key for MuckRack
      export GEMFURY_DEPLOY_TOKEN=$(cat /run/user/1000/mr_gemfury_deploy_token.txt)
      # Add private package index globally
      export PIP_EXTRA_INDEX_URL=$(cat /run/user/1000/mr_pip_extra_index_url.txt)
      # Add FontAwesome token globally
      export FONTAWESOME_NPM_AUTH_TOKEN=$(cat /run/user/1000/mr_fontawesome_npm_auth_token.txt)
    '';
  };

  #sops.secrets.mr_gemfury_deploy_token = {
  #  sopsFile = ../../starship/secrets.yaml;
  #};
}
