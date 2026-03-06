{
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    config = {
      whitelist = {
        prefix = [
          "$HOME/work/muckrack"
        ];
      };
    };
  };
}
