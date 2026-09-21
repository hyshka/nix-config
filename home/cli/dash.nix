{
  programs.gh-dash = {
    enable = true;
    settings = {
      defaults = {
        prApproveComment = "";
      };
      prSections = [
        {
          filters = "is:open author:@me";
          title = "My Pull Requests";
        }
        {
          filters = "is:open review-requested:@me";
          title = "Needs My Review";
        }
      ];
      notificationSections = [
        {
          filters = "";
          title = "All";
        }
      ];
      repoPaths = {
        "hyshka/nix-config" = "~/nix-config";
      };
    };
  };
}
