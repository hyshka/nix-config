{pkgs, ...}: {
  home.packages = [
    pkgs.mergiraf
  ];

  programs.git = {
    enable = true;
    userName = "hyshka";
    userEmail = "bryan@hyshka.com";
    signing = {
      key = "DB2D93D1BFAAA6EA";
      signByDefault = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
      status.showUntrackedFiles = "all";
      pull.rebase = true;
      merge = {
        ff = "only";
        conflictstyle = "zdiff3";
        tool = "nvimdiff2";
        mergiraf.name = "mergiraf";
        mergiraf.driver = "mergiraf merge --git %O %A %B -s %S -x %X -y %Y -p %P";
      };
      mergetool.keepBackup = false;
      column.ui = "auto";
      branch.sort = "-committerdate";
      tag.sort = "version:refname";
      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        mnemonicPrefix = true;
        renames = true;
      };
      push = {
        default = "simple";
        autoSetupRemote = true;
        followTags = true;
      };
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };
      help.autoCorrect = "prompt";
      commit.verbose = true;
      rerere = {
        enabled = true;
        autoUpdate = true;
      };
      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
      };
    };
    attributes = [
      "*.js merge=mergiraf"
      "*.jsx merge=mergiraf"
      "*.json merge=mergiraf"
      "*.yml merge=mergiraf"
      "*.yaml merge=mergiraf"
      "*.html merge=mergiraf"
    ];
    delta = {
      enable = true;
      options = {
        navigate = true;
      };
    };
    lfs.enable = true;
    ignores = [".direnv" "result"];
  };
}
