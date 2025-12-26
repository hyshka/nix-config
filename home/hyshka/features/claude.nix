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
    package = inputs.llm-agents.packages.${pkgs.system}.claude-code;
    settings = {
      includeCoAuthoredBy = false;
      defaultMode = "plan";
      hooks = hooks;
      allow = [
        # Safe read-only git commands
        "Bash(git add:*)"
        "Bash(git status)"
        "Bash(git log:*)"
        "Bash(git diff:*)"
        "Bash(git show:*)"
        "Bash(git branch:*)"
        "Bash(git remote:*)"

        # Safe Nix commands (mostly read-only)
        "Bash(nix:*)"

        # Safe file system operations
        "Bash(ls:*)"
        "Bash(find:*)"
        "Bash(grep:*)"
        "Bash(rg:*)"
        "Bash(cat:*)"
        "Bash(head:*)"
        "Bash(tail:*)"
        "Bash(mkdir:*)"
        "Bash(chmod:*)"

        # Safe Docker commands
        "Bash(docker container exec:*)"
        "Bash(docker compose exec:*)"

        # Core Claude Code tools
        "Glob(*)"
        "Grep(*)"
        "LS(*)"
        "Read(*)"
        "Search(*)"
        "Task(*)"
        "TodoWrite(*)"

        # Safe web fetch from trusted domains
        "WebFetch(domain:github.com)"
        "WebFetch(domain:raw.githubusercontent.com)"

        # GitHub tools (read-only)
        "mcp__github__search_repositories"
        "mcp__github__get_file_contents"

        # cclsp tools (read-only)
        "mcp__cclsp__find_definition"
        "mcp__cclsp__find_references"
        "mcp__cclsp__get_diagnostics"
        "mcp__cclsp__restart_server"
      ];
      deny = [
        "Read(**/.env*)"
        "Read(**/*.pem)"
        "Read(**/*.key)"
        "Read(**/.aws/**)"
        "Read(**/.ssh/**)"
      ];
    };
    mcpServers = {
      github = {
        type = "stdio";
        command = lib.getExe pkgs.github-mcp-server;
        args = [
          # NOTE: avoid accidentally causing unexpected changes with default MCP and allow list
          "--read-only"
          "stdio"
        ];
      };
      # requires lsp install/config: npx cclsp@latest setup
      cclsp = {
        type = "stdio";
        command = "npx";
        args = [
          "-y"
          "cclsp@latest"
        ];
        env = {
          CCLSP_CONFIG_PATH = "/Users/hyshka/.config/claude/cclsp.json";
        };
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
      socket = {
        type = "http";
        url = "https://mcp.socket.dev/";
      };
      context7 = {
        type = "http";
        url = "https://mcp.context7.com/mcp";
        headers = {
          "CONTEXT7_API_KEY" = ''\$${CONTEXT7_API_KEY}'';
        };
      };
    };
    memory.source = ./base.md;
  };
  xdg.configFile = {
    "cclsp" = {
      text = ''
          {
          "servers": [
            {
              "extensions": [
                "js",
                "ts",
                "jsx",
                "tsx"
              ],
              "command": [
                "npx",
                "--",
                "typescript-language-server",
                "--stdio"
              ],
              "rootDir": "."
            },
            {
              "extensions": [
                "py",
                "pyi"
              ],
              "command": [
                "uvx",
                "--from",
                "python-lsp-server",
                "pylsp"
              ],
              "rootDir": ".",
              "restartInterval": 5,
              "initializationOptions": {
                "settings": {
                  "pylsp": {
                    "plugins": {
                      "jedi_completion": {
                        "enabled": true
                      },
                      "jedi_definition": {
                        "enabled": true
                      },
                      "jedi_hover": {
                        "enabled": true
                      },
                      "jedi_references": {
                        "enabled": true
                      },
                      "jedi_signature_help": {
                        "enabled": true
                      },
                      "jedi_symbols": {
                        "enabled": true
                      },
                      "pylint": {
                        "enabled": false
                      },
                      "pycodestyle": {
                        "enabled": false
                      },
                      "pyflakes": {
                        "enabled": false
                      },
                      "yapf": {
                        "enabled": false
                      },
                      "rope_completion": {
                        "enabled": false
                      }
                    }
                  }
                }
              }
            },
            {
              "extensions": [
                "vue"
              ],
              "command": [
                "npx",
                "--",
                "vue-language-server",
                "--stdio"
              ],
              "rootDir": "."
            }
          ]
        }
      '';
      target = "claude/cclsp.json";
    };
  };
  home.packages = [
    inputs.llm-agents.packages.${pkgs.system}.claude-code-router
  ];
  xdg.configFile = {
    "claude-code-router" = {
      text = ''
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
      target = "../.claude-code-router/config.json";
    };
  };

}
