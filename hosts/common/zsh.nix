{pkgs, ...}: {
  # Allow users to use zsh shell
  programs.zsh.enable = true;
  environment.shells = with pkgs; [zsh];
  # Support completion for system packages
  # Ref: https://nix-community.github.io/home-manager/options.html#opt-programs.zsh.enableCompletion
  environment.pathsToLink = ["/share/zsh"];
}
