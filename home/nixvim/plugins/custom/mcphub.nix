{
  inputs,
  pkgs,
  ...
}: let
  mcp-hub = inputs.mcp-hub.packages."${pkgs.system}".default;
  mcphub-nvim = inputs.mcphub-nvim.packages."${pkgs.system}".default;
in {
  programs.nixvim = {
    extraPackages = [mcp-hub];
    extraPlugins = [mcphub-nvim];
    extraConfigLua = ''
      require("mcphub").setup({
        extensions = {
          copilotchat = {
            enabled = true,
            convert_tools_to_functions = true,
            convert_resources_to_functions = true,
            add_mcp_prefix = false,
          }
        }
      })
    '';
  };
  # TODO: declarative MCP server configuration
  #xdg.configFile = {
  #  "mcphub_servers" = {
  #    text = ''
  #      {}
  #    '';
  #    target = "mcphub/servers.json";
  #  };
  #};
}
