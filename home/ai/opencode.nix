{ inputs, pkgs, ... }:
{
  programs.opencode = {
    enable = true;
    package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
    rules = ./base.md;
    settings = {
      share = "disabled";
      autoupdate = false;
      model = "github-copilot/claude-sonnet-4.6";
      small_model = "github-copilot/claude-haiku-4.5";
      formatter = {
        nixfmt = {
          command = [
            "nix"
            "fmt"
            "$FILE"
          ];
          extensions = [
            ".nix"
          ];
        };
      };
      mcp = {
        context7 = {
          type = "remote";
          url = "https://mcp.context7.com/mcp";
          headers = {
            CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}";
          };
          enabled = true;
        };
        nixos = {
          type = "local";
          command = [
            "nix"
            "run"
            "github:utensils/mcp-nixos"
            "--"
          ];
          enabled = true;
        };
        gh_grep = {
          type = "remote";
          url = "https://mcp.grep.app";
          enabled = true;

        };
      };
      # TODO: upstream bug: Unrecognized key: "commands"
      #commands = {
      #  commit = ./commands/commit.md;
      #  review-changes = ./commands/review-changes.md;
      #  review-pr = ./commands/review-pr.md;
      #};
    };
    # TODO: reimplement notifications
    #"plugin-notification" = {
    #  text = ''
    #    export const NotificationPlugin = async ({ project, client, $, directory, worktree }) => {
    #      return {
    #        event: async ({ event }) => {
    #          // Send notification on session completion
    #          if (event.type === "session.idle") {
    #            await $`osascript -e 'display notification "Session completed!" with title "opencode"'`
    #          }
    #        },
    #      }
    #    }
    #  '';
    #  target = "opencode/plugin/notification.js";
    #};
    #"plugin-env" = {
    #  text = ''
    #    export const EnvProtection = async ({ project, client, $, directory, worktree }) => {
    #      return {
    #        "tool.execute.before": async (input, output) => {
    #          if (input.tool === "read" && output.args.filePath.includes(".env")) {
    #            throw new Error("Do not read .env files")
    #          }
    #        },
    #      }
    #    }
    #  '';
    #  target = "opencode/plugin/env-protection.js";
    #};
  };
}
