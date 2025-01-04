{pkgs, ...}: {
  imports = [
    ./bat.nix
    ./direnv.nix
    ./fzf.nix
    ./git.nix
    ./glances.nix
    ./gpg.nix
    ./ranger.nix
    ./sops.nix
    ./ssh.nix
    ./tmux.nix
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    bc # Calculator
    bottom # System viewer
    ncdu_1 # TUI disk usage
    eza # Better ls
    ripgrep # Better grep
    fd # Better find
    httpie # Better curl
    diffsitter # Better diff
    jq # JSON pretty printer and manipulator
    nix-melt # ranger-link flake.lock viewer
    silver-searcher # Better ack
    sd # Better sed
    unzip
    ctop # container stats
  ];
}
