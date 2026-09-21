{
  programs.gh-dash = {
    enable = true;
    settings = {
      defaults = {
        prApproveComment = "";
      };
      prSections = [
        {
          filters = "is:open author:@me sort:updated-desc";
          title = "Your pull requests";
        }
        {
          filters = "is:open user-review-requested:@me updated:>={{ nowModify '-1m' }} sort:updated-desc";
          title = "Needs your review";
        }
        {
          filters = "is:open team-review-requested-user:@me updated:>={{ nowModify '-1m' }} sort:updated-desc";
          title = "Needs your team's review";
        }
      ];
      repoPaths = {
        "hyshka/nix-config" = "~/nix-config";
      };
    };
  };
}
