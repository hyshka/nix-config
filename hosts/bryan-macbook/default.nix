{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.home-manager.darwinModules.home-manager

    ../common/global

    ./system.nix
    ./homebrew.nix
    ./user.nix
  ];

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
  # TODO: try input-leap
  # https://github.com/NixOS/nixpkgs/pull/341425

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
