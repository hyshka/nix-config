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
            }
          }
        }
      '';
      target = "opencode/opencode.json";
    };
  };
}
