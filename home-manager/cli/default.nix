{ pkgs, ... }: {
  imports = [
    ./bat.nix
    ./direnv.nix
    ./git.nix
    ./gpg.nix
    ./ranger.nix
    ./ssh.nix
    ./tmux.nix
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    bc # Calculator
    bottom # System viewer
    htop # System viewer
    ncdu # TUI disk usage
    exa # Better ls
    ripgrep # Better grep
    fd # Better find
    httpie # Better curl
    diffsitter # Better diff
    jq # JSON pretty printer and manipulator
    nix-melt # ranger-link flake.lock viewer
  ];
}
