{ inputs, pkgs, ... }:
{
  programs.claude-code = {
    enable = true;
    package = inputs.nix-ai-tools.packages.${pkgs.system}.claude-code;
    settings = {
      includeCoAuthoredBy = false;
      deny = [
        "Read(**/.env*)"
        "Read(**/*.pem)"
        "Read(**/*.key)"
        "Read(**/.aws/**)"
        "Read(**/.ssh/**)"
      ];
    };
    mcpServers = {
      shortcut = {
        command = "npm";
        args = [
          "-y"
          "@shortcut/mcp@latest"
        ];
        env = {
          SHORTCUT_API_TOKEN = ''\$${SHORTCUT_API_TOKEN}'';
        };
      };
      context7 = {
        type = "http";
        url = "https://mcp.context7.com/mcp";
        headers = {
          "CONTEXT7_API_KEY" = ''\$${CONTEXT7_API_KEY}'';
        };
      };
    };
  };
}
