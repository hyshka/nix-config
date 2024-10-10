# inputs.self, inputs.nix-darwin, and inputs.nixpkgs can be accessed here
{
  inputs,
  outputs,
  lib,
  ...
}: {
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # If you want to use modules from other flakes (such as nixos-hardware):
    inputs.home-manager.darwinModules.home-manager

    # You can also split up your configuration and import pieces of it here:
    ../common/nix.nix
    # Create /etc/zshrc that loads the nix-darwin environment.
    # this is required if you want to use darwin's default shell - zsh
    ../common/zsh.nix
    ../common/tailscale.nix
    ./system.nix
    ./homebrew.nix
    ./user.nix

    # Import your generated (nixos-generate-config) hardware configuration
    #./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      #outputs.overlays.additions
      #outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
  };

  # Ref:
  # https://daiderd.com/nix-darwin/manual/index.html
  # https://github.com/LnL7/nix-darwin

  # TODO things to check out, config via nix-darwin
  # https://karabiner-elements.pqrs.org/ (hotkeys)
  # https://github.com/FelixKratz/SketchyBar (status bar)
  # https://github.com/koekeishiya/skhd (hotkeys)
  # https://github.com/cmacrae/spacebar (status bar)

  # Synergy
  # https://symless.com/synergy (virtual kvm)
  # TODO: migrate to Deskflow: https://github.com/NixOS/nixpkgs/pull/346698
  services.synergy.client = {
    enable = false;
    screenName = "macbook";
    # The port overrides the default port, 24800.
    serverAddress = "10.0.0.230"; # ashyn
    # TODO tls requires product key
    # tls.enable = false;
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Optimise on schedule instead of during build due to MacOS bug
  # Ref: https://github.com/NixOS/nix/issues/7273
  nix.settings.auto-optimise-store = lib.mkForce false;
  nix.optimise.automatic = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";
}
