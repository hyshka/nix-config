{
  programs.nixvim = {
    # Highlight, edit, and navigate code
    # https://nix-community.github.io/nixvim/plugins/treesitter/index.html
    plugins.treesitter = {
      enable = true;

      settings = {
        highlight.enable = true;
        highlight.disable = ["vue"];
        indent.enable = true;
        ignore_install = [
          "org"
        ];
      };

      # There are additional nvim-treesitter modules that you can use to interact
      # with nvim-treesitter. You should go explore a few and see what interests you:
      #
      #    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
      #    - Treesitter + textobjects: https://nix-community.github.io/nixvim/plugins/treesitter-textobjects/index.html
    };

    # Support dockerfile type for files with periods in their name, e.g. Dockerfile.dev
    filetype.pattern = {
      "*.dockerignore" = "gitignore";
      "Dockerfile.*".__raw = ''
        function(path)
          return path:match("%.dockerignore%*?$") and "gitignore" or "dockerfile"
        end
      '';
    };

    # https://nix-community.github.io/nixvim/plugins/treesitter-context/index.html
    plugins.treesitter-context = {
      enable = true;
      settings = {
        max_lines = 2;
      };
    };

    # https://nix-community.github.io/nixvim/plugins/rainbow-delimiters/index.html
    plugins.rainbow-delimiters.enable = true;
  };
}
