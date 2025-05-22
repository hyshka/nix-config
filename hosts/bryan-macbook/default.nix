{
  inputs,
  outputs,
  lib,
  ...
}: {
  imports = [
    inputs.home-manager.darwinModules.home-manager

    # ../common/global/default.nix doesn't work for darwin as it includes nixosModules
    ../common/global/nix.nix
    ../common/global/nixpkgs.nix
    ../common/global/zsh.nix
    ../common/global/fonts.nix

    ./homebrew.nix
    ./system.nix
    ./users.nix
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.extraSpecialArgs = {
    inherit inputs outputs;
  };

  time.timeZone = "America/Edmonton";

  # Ref:
  # https://daiderd.com/nix-darwin/manual/index.html
  # https://github.com/LnL7/nix-darwin

  # TODO things to check out, config via nix-darwin
  # https://karabiner-elements.pqrs.org/ (hotkeys)
  # https://github.com/FelixKratz/SketchyBar (status bar)
  # https://github.com/koekeishiya/skhd (hotkeys)
  # https://github.com/cmacrae/spacebar (status bar)

  security.pam.services.sudo_local.touchIdAuth = true;

  # Optimise on schedule instead of during build due to MacOS bug
  # Ref: https://github.com/NixOS/nix/issues/7273
  nix.settings.auto-optimise-store = lib.mkForce false;
  nix.optimise.automatic = true;
  nix.settings.trusted-users = ["hyshka"];

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";
}
