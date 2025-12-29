# This file holds config shared across all darwin hosts
{
  ...
}:
{
  imports = [
    # Shared cross-platform modules
    ../../common/nix.nix
    ../../common/nixpkgs.nix
    ../../common/zsh.nix
    ../../common/fonts.nix
    # Note: sops.nix can be added here if darwin hosts need secrets
  ];
}
