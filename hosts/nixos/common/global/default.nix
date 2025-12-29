# This file (and the global directory) holds config that i use on all hosts
{
  outputs,
  ...
}:
{
  imports = [
    # Shared cross-platform modules
    ../../common/nix.nix
    ../../common/nixpkgs.nix
    ../../common/zsh.nix
    ../../common/fonts.nix
    ../../common/sops.nix

    # NixOS-specific modules
    ./catppuccin.nix
    ./locale.nix
    #./nameservers.nix
    ./openssh.nix
    ./tailscale.nix
  ]
  ++ (builtins.attrValues outputs.nixosModules);

  hardware.enableRedistributableFirmware = true;
}
