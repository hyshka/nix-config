{ inputs, pkgs, ... }:
{
  programs.opencode = {
    enable = true;
    package = inputs.nix-ai-tools.packages.${pkgs.system}.opencode;
  };
  xdg.configFile = {
    "opencode" = {
      text = ''
        {
          "$schema": "https://opencode.ai/config.json",
          "theme": "catppuccin",
          "share": "disabled",
          "autoupdate": false,
          "model": "github-copilot/claude-sonnet-4.5",
          "small_model": "github-copilot/claude-haiku-4.5",
          "formatter": {
            "nixfmt": {
              "command": [
                "nix",
                "fmt",
                "$FILE"
              ],
              "extensions": [
                ".nix",
              ]
            },
            "prettier": {
              "command": [
                "docker compose exec frontend yarn",
                "prettier",
                "--write",
                "$FILE"
              ],
              "extensions": [
                ".js",
                ".ts",
                ".json",
                ".vue",
                ".scss",
                ".css"
              ]
            },
            "ruff": {
              "command": [
                "docker compose exec web",
                "ruff",
                "format",
                "$FILE"
              ],
            },
          },
          "mcp": {
            "context7": {
              "type": "remote",
              "url": "https://mcp.context7.com/mcp",
              "headers": {
                "CONTEXT7_API_KEY": "{env:CONTEXT7_API_KEY}"
              },
              "enabled": true
            },
            "nixos": {
              "type": "local",
              "command": [
                "nix",
                "run",
                "github:utensils/mcp-nixos",
                "--"
              ],
              "enabled": true
            },
            "github": {
              "type": "local",
              "command": [
                "nix",
                "run",
                "nixpkgs#github-mcp-server",
                "--",
                "--read-only",
                "stdio"
              ],
              "enabled": true
            }
          }
        }
      '';
      target = "opencode/opencode.json";
    };
    "command-commit" = {
      source = ./command/commit.md;
      target = "opencode/command/commit.md";
    };
    "command-review-changes" = {
      source = ./command/review-changes.md;
      target = "opencode/command/review-changes.md";
    };
    "plugin-notification" = {
      text = ''
        export const NotificationPlugin = async ({ project, client, $, directory, worktree }) => {
          return {
            event: async ({ event }) => {
              // Send notification on session completion
              if (event.type === "session.idle") {
                await $`osascript -e 'display notification "Session completed!" with title "opencode"'`
              }
            },
          }
        }
      '';
      target = "opencode/plugin/notification.js";
    };
    "plugin-env" = {
      text = ''
        export const EnvProtection = async ({ project, client, $, directory, worktree }) => {
          return {
            "tool.execute.before": async (input, output) => {
              if (input.tool === "read" && output.args.filePath.includes(".env")) {
                throw new Error("Do not read .env files")
              }
            },
          }
        }
      '';
      target = "opencode/plugin/env-protection.js";
    };
  };
}
