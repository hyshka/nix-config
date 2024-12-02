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
      pull.rebase = true;
      push.default = "simple";
      push.autoSetupRemote = true;
      status.showUntrackedFiles = "all";
      merge.ff = "only";
      merge.conflictstyle = "zdiff3";
      mergetool.keepBackup = false;
      merge.mergiraf.name = "mergiraf";
      merge.mergiraf.driver = "mergiraf merge --git %O %A %B -s %S -x %X -y %Y -p %P";
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
