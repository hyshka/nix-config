{ pkgs, ... }: {
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
    '';
  };
}
