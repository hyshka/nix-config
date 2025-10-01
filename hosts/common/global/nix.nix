{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    package = pkgs.nixVersions.latest;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes ca-derivations";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
      warn-dirty = false;
      trusted-substituters = [
        "https://nix-community.cachix.org"
        "https://mic92.cachix.org"
        "https://nix-darwin.cachix.org"
        "https://catppuccin.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "mic92.cachix.org-1:gi8IhgiT3CYZnJsaW7fxznzTkMUOn1RY4GmXdT/nXYQ="
        "nix-darwin.cachix.org-1:LxMyKzQk7Uqkc1Pfq5uhm9GSn07xkERpy+7cpwc006A="
        "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
      ];
      trusted-users = [ "@wheel" ];
    };

    gc = {
      automatic = true;
      # Delete older generations too
      options = "--delete-older-than 7d";
    };
  };
}
