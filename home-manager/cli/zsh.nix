{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    autocd = true;
    defaultKeymap = "viins";
    enableAutosuggestions = true;
    enableCompletion = false;
    enableSyntaxHighlighting = true;
    programs.zsh.syntaxHighlighting.highlighters = [ "main" "brackets" "cursor" ];
    historySubstringSearch.enable = true;
    history = {
      ignoreDups = true;
      expireDuplicatesFirst = true;
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
	"$PATH_TO_LOCAL_MODULE" # path must exist as env var
        "duration-info"
        "git-info"
        "asciiship"
	"zsh-users/zsh-completions --fpath src" # is supposed be before completion
        "completion"
	# must come after completion
        # zsh-users/zsh-autosuggestions
        # zsh-users/zsh-syntax-highlighting
        # zsh-users/zsh-history-substring-search
      ];
    };
    initExtra = ''
      # zimfw config
      zstyle ':zim:input' double-dot-expand yes
    '';
  };
}
