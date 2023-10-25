{ pkgs, ... }: {
  programs.neovim = {
    extraPackages = with pkgs; [
      nodejs_20
    ];
    plugins = with pkgs.vimPlugins; [
      {
        plugin = copilot-lua;
        type = "lua";
        config = /* lua */ ''
          require('copilot').setup({
            copilot_node_command = '${pkgs.nodejs_20}/bin/node',
          })
        '';
      }
    ];
  };
}
