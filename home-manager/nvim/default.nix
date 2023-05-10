{ config, pkgs, ... }:
let
  color = pkgs.writeText "color.vim" (import ./theme.nix config.colorscheme);
in
{
  imports = [
    ./lsp.nix
    ./syntaxes.nix
    ./ui.nix
  ];
  home.sessionVariables.EDITOR = "nvim";

  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;

    # TODO config
    extraConfig = /* vim */ ''
    '';
    extraLuaConfig = /* lua */ ''
    '';

    plugins = with pkgs.vimPlugins; [
      # core
      vim-sensible
      vim-surround
      vim-repeat
      vim-unimpaired
      vim-tmux-focus-events

      # navigation
      ranger-vim
      popup-nvim
      plenary-nvim
      telescope-nvim
      telescope-fzf-native-nvim # do make?

      # languages
      null-ls-nvim
      SchemaStore-nvim
      vim-LanguageTool

      # other
      nerdcommenter
      emmet-vim
      vim-argwrap
      targets-vim
    ];
  };

  xdg.configFile."nvim/init.lua".onChange = ''
    XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
    for server in $XDG_RUNTIME_DIR/nvim.*; do
      nvim --server $server --remote-send ':source $MYVIMRC<CR>' &
    done
  '';

  xdg.desktopEntries = {
    nvim = {
      name = "Neovim";
      genericName = "Text Editor";
      comment = "Edit text files";
      exec = "nvim %F";
      icon = "nvim";
      mimeType = [
        "text/english"
        "text/plain"
        "text/x-makefile"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
        "application/x-shellscript"
        "text/x-c"
        "text/x-c++"
      ];
      terminal = true;
      type = "Application";
      categories = [ "Utility" "TextEditor" ];
    };
  };
}
