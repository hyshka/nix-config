{ pkgs, ... }:
{
  home.packages = [
    pkgs.mergiraf
  ];

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "hyshka";
        email = "bryan@hyshka.com";
      };
      init.defaultBranch = "main";
      status.showUntrackedFiles = "all";
      pull.rebase = true;
      merge = {
        ff = "only";
        conflictstyle = "zdiff3";
        tool = "nvimdiff2";
        mergiraf.name = "mergiraf";
        mergiraf.driver = "mergiraf merge --git %O %A %B -s %S -x %X -y %Y -p %P -l %L";
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
      "*.py merge=mergiraf"
      "*.js merge=mergiraf"
      "*.jsx merge=mergiraf"
      "*.ts merge=mergiraf"
      "*.tsx merge=mergiraf"
      "*.mjs merge=mergiraf"
      "*.json merge=mergiraf"
      "*.yml merge=mergiraf"
      "*.yaml merge=mergiraf"
      "pyproject.toml merge=mergiraf"
      "*.toml merge=mergiraf"
      "*.html merge=mergiraf"
      "*.nix merge=mergiraf"
      "*.go merge=mergiraf"
      "*.rs merge=mergiraf"
      "Makefile merge=mergiraf"
    ];
    lfs.enable = true;
    ignores = [
      ".direnv"
      "result"
    ];
    signing = {
      key = "DB2D93D1BFAAA6EA";
      signByDefault = true;
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      "side-by-side" = true;
      hyperlinks = true;
      "map-styles" = "bold purple => syntax magenta, bold cyan => syntax blue";
    };
  };
}
