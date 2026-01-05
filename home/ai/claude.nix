{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  hookFiles = [
    ./hooks/notification.nix
    ./hooks/subagent-stop.nix
  ];
  hooks = builtins.foldl' (acc: file: acc // (import file { inherit pkgs; })) { } hookFiles;
in
{
  programs.claude-code = {
    enable = true;
    package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
    settings = {
      includeCoAuthoredBy = false;
      env = {
        CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
        DISABLE_NON_ESSENTIAL_MODEL_CALLS = "1";
      };
      statusLine = {
        type = "command";
        command = "input=$(cat); model=$(echo \"$input\" | jq -r '.model.display_name'); dir=$(echo \"$input\" | jq -r '.workspace.current_dir' | sed -E 's:/*$::' | awk -F/ '{if(NF>=2){print $(NF-1) \"/\" $(NF)} else if(NF==1){print $(NF)}}'); usage=$(echo \"$input\" | jq '.context_window.current_usage'); if [ \"$usage\" != \"null\" ]; then current=$(echo \"$usage\" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens'); size=$(echo \"$input\" | jq '.context_window.context_window_size'); pct=$((current * 100 / size)); printf '%s | %s | %d%% context' \"$model\" \"$dir\" \"$pct\"; else printf '%s | %s | 0%% context' \"$model\" \"$dir\"; fi";
      };
      hooks = hooks;
      enabledPlugins = {
        "pyright-lsp@claude-plugins-official" = true;
        "typescript-lsp@claude-plugins-official" = true;
      };
      permissions = {
        defaultMode = "plan";
        allow = [
          # Safe read-only git commands
          "Bash(git add:*)"
          "Bash(git status:*)"
          "Bash(git log:*)"
          "Bash(git diff:*)"
          "Bash(git show:*)"
          "Bash(git branch:*)"
          "Bash(git remote:*)"

          # Nix commands
          "Bash(nix:*)"
          "Bash(nh search:*)"

          # Safe file system operations
          "Bash(ls:*)"
          "Bash(find:*)"
          "Bash(grep:*)"
          "Bash(ag:*)"
          "Bash(rg:*)"
          "Bash(cat:*)"
          "Bash(head:*)"
          "Bash(tail:*)"
          "Bash(mkdir:*)"
          "Bash(chmod:*)"

          # Safe Docker commands
          "Bash(docker container exec:*)"
          "Bash(docker compose exec:*)"

          # Safe gh CLI commands
          "Bash(gh pr list:*)"
          "Bash(gh pr status:*)"
          "Bash(gh pr checks:*)"
          "Bash(gh pr diff:*)"
          "Bash(gh pr view:*)"
          "Bash(gh repo list:*)"
          "Bash(gh repo view:*)"

          # Safe web fetch and search from trusted domains
          "WebFetch(domain:github.com)"
          "WebFetch(domain:raw.githubusercontent.com)"

          # MCP permissions (read-only)
          "mcp__context7"
          "mcp__gh_grep"
          "mcp__nixos"
          "mcp__github__search_repositories"
          "mcp__github__get_file_contents"
        ];
        ask = [
          "Bash(git push:*)"
          "Bash(git commit:*)"
        ];
        deny = [
          "Read(**/.env*)"
          "Read(**/*.pem)"
          "Read(**/*.key)"
          "Read(**/.aws/**)"
          "Read(**/.ssh/**)"
          "Bash(rm -rf /*)"
          "Bash(rm -rf /)"
          "Bash(dd:*)"
        ];
      };
    };
    mcpServers = {
      context7 = {
        type = "http";
        url = "https://mcp.context7.com/mcp";
        headers = {
          "CONTEXT7_API_KEY" = ''\$${CONTEXT7_API_KEY}'';
        };
      };
      gh_grep = {
        type = "http";
        url = "https://mcp.grep.app";
      };
      github = {
        type = "stdio";
        command = lib.getExe pkgs.github-mcp-server;
        args = [
          # NOTE: avoid accidentally causing unexpected changes with default MCP and allow list
          "--read-only"
          "stdio"
        ];
      };
      shortcut = {
        type = "stdio";
        command = "npx";
        args = [
          "-y"
          "@shortcut/mcp@latest"
        ];
        env = {
          SHORTCUT_API_TOKEN = ''\$${SHORTCUT_API_TOKEN}'';
          # Limit tools to use less context
          SHORTCUT_TOOLS = "stories,epics,teams,workflows";
        };
      };
    };
    memory.source = ./base.md;
  };

  programs.git.ignores = [ "**/.claude/settings.local.json" ];

  # -----
  # Dependencies
  # -----
  home.packages = [
    # Status line dependencies
    pkgs.jq
    # LSP dependencies
    pkgs.typescript-language-server
    pkgs.pyright
    pkgs.vue-language-server
    pkgs.nil
    # MCP dependencies
    pkgs.nodejs_24
    pkgs.yarn
    pkgs.uv
    # Claude Code Router
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code-router
    # GH CLI is cheaper than Github MCP for some operations
    pkgs.gh
  ];

  # TODO: vue-lsp or nil isn't supported by a claude plugin yet
  home.file.".claude/.lsp.json" = {
    text = /* json */ ''
      {
        "vue": {
          "command": "vue-language-server",
          "extensionToLanguage": {
            ".vue": "vue"
          }
        },
        "nix": {
          "command": "nil",
          "extensionToLanguage": {
            ".nix": "nix"
          }
        }
      }
    '';
  };

  # -----
  # Claude Code Router
  # For personal use with OpenRouter
  # -----
  home.file.".claude-code-router/config.json" = {
    text = /* json */ ''
      {
        "Providers": [
          {
            "name": "openrouter",
            "api_base_url": "https://openrouter.ai/api/v1/chat/completions",
            "api_key": "$OPENROUTER_API_KEY",
            "models": [
              "anthropic/claude-haiku-4.5:online",
              "anthropic/claude-sonnet-4.5",
              "anthropic/claude-opus-4.5"
            ],
            "transformer": {
              "use": ["openrouter"]
            }
          }
        ],
        "Router": {
          "default": "openrouter,anthropic/claude-sonnet-4.5",
          "background": "openrouter,anthropic/claude-haiku-4.5",
          "think": "openrouter,anthropic/claude-opus-4.5",
          "longContext": "openrouter,anthropic/claude-sonnet-4.5",
          "webSearch": "openrouter,anthropic/claude-haiku-4.5",
          "image": "openrouter,anthropic/claude-sonnet-4.5"
        }
      }
    '';
  };
}
