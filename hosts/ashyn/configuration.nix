{
  inputs,
  outputs,
  ...
}: {
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # If you want to use modules from other flakes (such as nixos-hardware):
    #inputs.hardware.nixosModules.common-pc-ssd
    #inputs.hardware.nixosModules.common-cpu-amd-pstate
    #inputs.hardware.nixosModules.common-gpu-amd
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
