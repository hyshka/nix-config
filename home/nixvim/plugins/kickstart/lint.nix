{pkgs, ...}: {
  programs.nixvim = {
    # Linting
    # https://nix-community.github.io/nixvim/plugins/lint/index.html
    plugins.lint = {
      enable = true;

      # NOTE: Enabling these will cause errors unless these tools are installed
      lintersByFt = {
        nix = ["alejandra"];
        markdown = [
          "markdownlint"
          #vale
        ];
        #clojure = ["clj-kondo"];
        #dockerfile = ["hadolint"];
        #inko = ["inko"];
        #janet = ["janet"];
        #json = ["jsonlint"];
        #rst = ["vale"];
        #ruby = ["ruby"];
        #terraform = ["tflint"];
        #text = ["vale"];
        typescript = ["eslint_d"];
        javascript = ["eslint_d"];
        vue = ["eslint_d"];
      };
      linters = {
        alejandra.cmd = "${pkgs.alejandra}/bin/alejandra";
        markdown.cmd = "${pkgs.markdownlint-cli}/bin/markdownlint";
        eslint_d.cmd = "${pkgs.eslint_d}/bin/eslint_d";
      };

      # Create autocommand which carries out the actual linting
      # on the specified events.
      autoCmd = {
        callback.__raw = ''
          function()
            require('lint').try_lint()
          end
        '';
        group = "lint";
        event = [
          "BufEnter"
          "BufWritePost"
          "InsertLeave"
        ];
      };
    };

    # https://nix-community.github.io/nixvim/NeovimOptions/autoGroups/index.html
    autoGroups = {
      lint = {
        clear = true;
      };
    };
  };
}
