{ config, ... }: {
  programs.git = {
    enable = true;
    userName = "hyshka";
    userEmail = "bryan@hyshka.com";
    signing = {
      key = "DB2D93D1BFAAA6EA";
      signByDefault = true;
      #gpgPath = "${config.programs.gpg.package}/bin/gpg2";
    };
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.default = "simple";
      push.autoSetupRemote = true;
      status.showUntrackedFiles = "all";
      merge.ff = "only";
      merge.conflictstyle = "diff3";
      mergetool.keepBackup = false;
    };
    delta.enable = true;
    lfs.enable = true;
    ignores = [ ".direnv" "result" ];
  };
}
