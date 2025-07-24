{pkgs, ...}: {
  programs.ranger = {
    enable = true;
    package = pkgs.ranger.overrideAttrs (prev: {
      makeWrapperArgs = ["--set BAT_STYLE full"];
      preConfigure = let
        json_bat_cmd = ''jq . "''${FILE_PATH}" | env COLORTERM=8bit bat --language json --color=always --style="''${BAT_STYLE}" \&\& exit 5'';
      in
        prev.preConfigure
        + ''
          sed -i -e '/#\s*application\/pdf/,/&& exit 6/s/#//' ranger/data/scope.sh
          sed -i -e '/#\s*video/,/exit 1/s/#//' ranger/data/scope.sh
          sed -i -e '/#\s*image\/svg/,/exit 1/s/#//' ranger/data/scope.sh
          sed -i -e 's/json)/&\n\t\t\t${json_bat_cmd}/' ranger/data/scope.sh
          sed -i -e '/handle_mime() {/,/esac/s/case "''${mimetype}" in/&\n\n\t\tapplication\/json) ${json_bat_cmd} ;;\n/' ranger/data/scope.sh
          sed -i -e 's/text\/\* | \*\/xml)/text\/* | *\/xml | application\/javascript)/g' ranger/data/scope.sh
        '';
    });
    extraPackages = with pkgs; [
      (python3.withPackages (python-pkgs:
        with python-pkgs; [
          pygments # syntax highlighting
          setuptools # for building ranger plugins
        ]))
      bat # syntax highlighting
      w3m # image preview
      librsvg # svg preview
      ffmpegthumbnailer # video thumbs
      poppler_utils # pdf preview
      exiftool # media meta data
      odt2txt # odt preview
      jq # json preview
      fontforge # font preview
    ];
    settings = {
      wrap_scroll = true;
      vcs_aware = true;
      line_numbers = "relative";
      collapse_preview = false;
      draw_borders = "both";
      show_hidden = true;
      preview_images = true;
      unicode_ellipsis = true;
    };
    mappings = {
      "<C-f>" = "fzf_select";
    };
  };
  xdg.configFile."ranger/commands.py".source = ./ranger_commands.py;
}
