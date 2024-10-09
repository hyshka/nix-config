{
  inputs,
  outputs,
  pkgs,
  ...
}: {
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # If you want to use modules from other flakes (such as nixos-hardware):
    #inputs.hardware.nixosModules.common-cpu-intel
    #inputs.hardware.nixosModules.common-pc-laptop
    inputs.sops-nix.nixosModules.sops

    # You can also split up your configuration and import pieces of it here:
    ../common/nix.nix
    ../common/zsh.nix
    ../common/tailscale.nix
    ../common/catppuccin.nix
    ../starship/users.nix
    ../starship/bluetooth.nix

    # TODO
    #./desktop.nix
    #./synergy.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
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

  # TODO: move to modules
  # KDE
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.defaultSession = "plasma";
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = [pkgs.kdePackages.konsole];

  # Audio
  security.rtkit.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Accellerated video
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      # this is for jasper lake
      intel-media-sdk
    ];
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh = {
    enable = true;
    # Obfuscate port
    ports = [38002];
  };

  networking.hostName = "ashyn";
  networking.nameservers = [
    # tiny1 adguardhome
    "10.0.0.240"
  ];

  sops.defaultSopsFile = ./secrets.yaml;

  # Set your time zone.
  time.timeZone = "America/Edmonton";

  # https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "24.05";
}
