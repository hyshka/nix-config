# inputs.self, inputs.nix-darwin, and inputs.nixpkgs can be accessed here
{ inputs, outputs, pkgs, lib, config, ... }:
{
  imports =
    [
      # If you want to use modules your own flake exports (from modules/nixos):
      # outputs.nixosModules.example

      # If you want to use modules from other flakes (such as nixos-hardware):
      inputs.home-manager.darwinModules.home-manager

      # You can also split up your configuration and import pieces of it here:
      ../common/nix.nix
      # Create /etc/zshrc that loads the nix-darwin environment.
      # this is required if you want to use darwin's default shell - zsh
      ../common/zsh.nix
      ./system.nix
      ./homebrew.nix
      ./user.nix

      # Import your generated (nixos-generate-config) hardware configuration
      #./hardware-configuration.nix
    ];

  # Ref:
  # https://daiderd.com/nix-darwin/manual/index.html
  # https://github.com/LnL7/nix-darwin

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
  #environment.systemPackages = with pkgs; [ ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";
}
