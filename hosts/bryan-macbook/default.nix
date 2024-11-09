{
  inputs,
  outputs,
  lib,
  ...
}: {
  imports = [
    inputs.home-manager.darwinModules.home-manager

    # TODO: this probably won't wook for darwin as it includes nixosModules
    #../common/global
    ../common/global/nix.nix
    ../common/global/zsh.nix

    ./homebrew.nix
    ./system.nix
    ./users.nix
  ];

  home-manager.sharedModules =
    [
      inputs.catppuccin.homeManagerModules.catppuccin
    ]
    ++ (builtins.attrValues outputs.homeManagerModules);
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.extraSpecialArgs = {
    inherit inputs outputs;
  };
  home-manager.users.hyshka = import ./home.nix;

  # TODO: move to nixpkgs module in global?
  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
    };
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

  # Virtual KVM
  # TODO: migrate to Deskflow: https://github.com/NixOS/nixpkgs/pull/346698
  # TODO: try input-leap
  # https://github.com/NixOS/nixpkgs/pull/341425

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

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
