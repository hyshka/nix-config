{ pkgs, ... }:
let
  yazi-plugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "main";
    hash = "sha256-5dMAJ6W/L66XuH4CCwRRFpKSLy0ZDFIABAYleFX0AsQ=";
  };
in
{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      mgr = {
        show_hidden = true;
        sort_by = "natural";
        sort_sensitive = false;
        sort_dir_first = true;
        linemode = "size";
        scrolloff = 5;
      };
      preview = {
        wrap = "yes";
        tab_size = 2;
      };
      # Git plugin fetchers
      plugin = {
        prepend_fetchers = [
          {
            id = "git";
            name = "*";
            run = "git";
          }
          {
            id = "git";
            name = "*/";
            run = "git";
          }
        ];
      };
    };

    keymap = {
      mgr.prepend_keymap = [
        # fzf file search (equivalent to ranger's <C-f>)
        {
          on = [ "<C-f>" ];
          run = "plugin zoxide";
          desc = "Jump via zoxide";
        }
        # Quick bookmarks
        {
          on = [
            "g"
            "h"
          ];
          run = "cd ~";
          desc = "Go home";
        }
        {
          on = [
            "g"
            "d"
          ];
          run = "cd ~/Downloads";
          desc = "Go Downloads";
        }
        {
          on = [
            "g"
            "c"
          ];
          run = "cd ~/nix-config";
          desc = "Go nix-config";
        }
      ];
    };

    plugins = {
      git = "${yazi-plugins}/git.yazi";
    };

    initLua = ''
      require("git"):setup()
    '';

    # Catppuccin theme is automatically applied via global catppuccin module
    # (home/hyshka/global.nix sets catppuccin.flavor = "frappe")

    extraPackages = with pkgs; [
      ueberzugpp # image previews
      ffmpeg # video thumbnails
      poppler # PDF preview
      p7zip # archive extraction and preview
      zoxide # directory jumping
      resvg # SVG preview
      imagemagick # Font, HEIC, and JPEG XL preview
      wl-clipboard # clipboard support
      jq # JSON preview
      exiftool # media metadata
      odt2txt # ODT preview
      # Configured in other modules:
      # fzf (for quick file subtree navigation)
      # rg (for file content searching)
      # fd (for file searching)
    ];
  };
}
