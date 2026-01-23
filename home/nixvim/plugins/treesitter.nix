{ pkgs, ... }:
{
  programs.nixvim = {
    plugins.treesitter = {
      enable = true;
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        c
        javascript
        typescript
        tsx
        jsdoc
        html
        css
        scss
        #vue # There is no up-to-date treesitter parser for Vue currently, rely on LSP isntead
        bash
        ssh_config
        sway
        tmux
        jq
        zsh
        gpg
        just
        passwd
        nix
        query
        vim
        vimdoc
        lua
        luadoc
        csv
        tsv
        diff
        editorconfig
        git_config
        git_rebase
        gitattributes
        gitcommit
        gitignore
        ini
        markdown
        markdown_inline
        regex
        xml
        json
        yaml
        toml
        dockerfile
        make
        robots_txt
        rust
        go
        gomod
        gosum
        zig
        helm
        terraform
        php
        http
        sql
        nginx
        svelte
        mermaid
        graphql
        htmldjango
        requirements
        python
        helm
      ];

      settings = {
        highlight.enable = true;
        indent.enable = true;
        #folding.enable = true;
      };
      nixvimInjections = true;
    };

    # Support dockerfile type for files with periods in their name, e.g. Dockerfile.dev
    filetype.pattern = {
      "*.dockerignore" = "gitignore";
      "*.vitest.js" = "javascript";
      "*.vitest.ts" = "typescript";
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

    # Auto-close and auto-rename HTML/JSX/Vue tags
    # https://nix-community.github.io/nixvim/plugins/ts-autotag/index.html
    plugins.ts-autotag = {
      enable = true;
      settings = {
        opts = {
          enable_close = true;
          enable_rename = true;
          enable_close_on_slash = false;
        };
      };
    };
  };

}
