{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  isLinux = pkgs.stdenv.isLinux;
in {
  nixpkgs = {
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    package = pkgs.nixVersions.nix_2_18;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
      warn-dirty = false;
    };

    gc = {
      automatic = true;
      # Delete older generations too
      options = "--delete-older-than 7d";
    };
    gc.dates = lib.mkIf isLinux "weekly";
    # gc.interval defaults to daily on darwin
  };
}
