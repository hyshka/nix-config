# This file (and the global directory) holds config that i use on all hosts
{
  outputs,
  ...
}:
{
  imports = [
    ./catppuccin.nix
    ./locale.nix
    #./nameservers.nix
    ./nix.nix
    ./nixpkgs.nix
    ./openssh.nix
    ./sops.nix
    ./tailscale.nix
    ./zsh.nix
  ]
  ++ (builtins.attrValues outputs.nixosModules);

  hardware.enableRedistributableFirmware = true;
}
