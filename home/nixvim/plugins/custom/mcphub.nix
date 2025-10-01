{
  inputs,
  pkgs,
  ...
}:
let
  mcp-hub = inputs.mcp-hub.packages."${pkgs.system}".default;
  mcphub-nvim = inputs.mcphub-nvim.packages."${pkgs.system}".default;
in
{
  programs.nixvim = {
    extraPackages = [ mcp-hub ];
    extraPlugins = [ mcphub-nvim ];
    extraConfigLua = ''
      require("mcphub").setup()
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
