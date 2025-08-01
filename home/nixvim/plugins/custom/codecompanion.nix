{...}: {
  programs.nixvim = {
    plugins.codecompanion = {
      enable = true;
      settings = {
        extensions = {
          mcphub = {
            callback = "mcphub.extensions.codecompanion";
            opts = {
              make_tools = true;
              show_server_tools_in_chat = true;
              add_mcp_prefix_to_tool_names = false;
              show_result_in_chat = true;
              format_tool = null;
              make_vars = true;
              make_slash_commands = true;
            };
          };
        };
      };
    };
  };
}
