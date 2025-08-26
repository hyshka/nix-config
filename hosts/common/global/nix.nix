{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  isLinux = pkgs.stdenv.isLinux;
in {
  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

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
        "mic92.cachix.org-1:Fhn3812iR2y2BvD4sU5vUIp9gJ232o1Z2e/s06Mv22o="
        "nix-darwin.cachix.org-1:5_2rI+3hRmy7M9rQpDIFj3y7a2b/G42iLY6S+Gfa32c="
        "catppuccin.cachix.org-1:aU5vjCfsS1Z1t1I9nC42cQli42QGj28H3/2SYe2d320="
      ];
      trusted-users = ["@wheel"];
    };

    gc = {
      automatic = true;
      # Delete older generations too
      options = "--delete-older-than 7d";
    };
  };
}
