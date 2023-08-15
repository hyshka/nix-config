# inputs.self, inputs.nix-darwin, and inputs.nixpkgs can be accessed here
{ inputs, outputs, pkgs, lib, config, ... }:
{
  imports =
    [
      # If you want to use modules your own flake exports (from modules/nixos):
      # outputs.nixosModules.example

      # If you want to use modules from other flakes (such as nixos-hardware):
      inputs.home-manager.darwinModules.home-manager
      #inputs.sops-nix.nixosModules.sops

      # You can also split up your configuration and import pieces of it here:
      # TODO
      #../starship/nix.nix
      # Create /etc/zshrc that loads the nix-darwin environment.
      # this is required if you want to use darwin's default shell - zsh
      ../starship/shell.nix
      # TODO security.pam is not an option on darwin
      #../starship/sshd.nix
      # osx settings
      ./system.nix
      ./homebrew.nix
      ./user.nix

      # Import your generated (nixos-generate-config) hardware configuration
      #./hardware-configuration.nix
    ];

  # Ref:
  # http://daiderd.com/nix-darwin/
  # https://github.com/LnL7/nix-darwin

  # TODO merge with ./starship/nix.nix once I figue out how to pass different
  # options
  # isDarwin = pkgs.stdenv.isDarwin;
  # Ref: https://github.com/mitchellh/nixos-config/blob/main/users/mitchellh/home-manager.nix#L5C3-L5C35
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
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
      warn-dirty = false;
    };

    gc = {
      automatic = true;
      # TODO weekly interval?
      # interval = "weekly";
      # Delete older generations too
      options = "--delete-older-than 7d";
    };
  };
  # end nix module


  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Install packages from nix's official package repository.
  #
  # The packages installed here are available to all users, and are reproducible across machines, and are rollbackable.
  # But on macOS, it's less stable than homebrew.
  #
  # Related Discussion: https://discourse.nixos.org/t/darwin-again/29331
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  # environment.systemPackages = with pkgs; [];

  # override starship port
  #TODO
  #services.openssh.ports = [ 38002 ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";
}
