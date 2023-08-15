# inputs.self, inputs.nix-darwin, and inputs.nixpkgs can be accessed here
{ inputs, outputs, pkgs, lib, ... }:
{
  # Ref:
  # http://daiderd.com/nix-darwin/
  # https://github.com/LnL7/nix-darwin

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.vim
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
  # programs.fish.enable = true;


  system.defaults.NSGlobalDomain."com.apple.sound.beep.volume" = 0.0;
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";
}
