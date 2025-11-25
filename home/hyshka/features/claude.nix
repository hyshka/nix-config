{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  programs.claude-code = {
    enable = true;
    package = inputs.nix-ai-tools.packages.${pkgs.system}.claude-code;
    settings = {
      includeCoAuthoredBy = false;
      defaultMode = "plan";
      hooks = map (f: import f { inherit pkgs; }) [
        ./hooks/notification.nix
        ./hooks/subagent-stop.nix
      ];
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
        "Bash(docker container exec *)"

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
      shortcut = {
        type = "stdio";
        command = "npx";
        args = [
          "-y"
          "@shortcut/mcp@latest"
        ];
        env = {
          SHORTCUT_API_TOKEN = ''\$${SHORTCUT_API_TOKEN}'';
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
}
