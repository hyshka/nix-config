# https://github.com/nvim-orgmode/orgmode
{
  programs.nixvim.plugins.orgmode = {
    enable = true;
    settings = {
      org_agenda_files = "~/orgfiles/**/*";
      org_default_notes_file = "~/orgfiles/refile.org";
    };
  };

  programs.nixvim.plugins.cmp.settings.sources = [
    {
      name = "orgmode";
    }
  ];
}
