# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)

{ inputs, outputs, lib, config, pkgs, ... }:
  let ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  imports =
    [
      # If you want to use modules your own flake exports (from modules/nixos):
      # outputs.nixosModules.example

      # If you want to use modules from other flakes (such as nixos-hardware):
      inputs.hardware.nixosModules.common-pc
      inputs.hardware.nixosModules.common-pc-ssd
      inputs.hardware.nixosModules.common-cpu-amd
      #inputs.hardware.nixosModules.common-cpu-amd-pstate
      inputs.hardware.nixosModules.common-gpu-amd
      inputs.hardware.nixosModules.common-hidpi

      # You can also split up your configuration and import pieces of it here:
      # ./users.nix

      # Import your generated (nixos-generate-config) hardware configuration
      ./hardware-configuration.nix
    ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
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
      dates = "weekly";
      # Delete older generations too
      options = "--delete-older-than 7d";
    };
  };

  networking.hostName = "starship"; # Define your hostname.

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "America/Edmonton";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  #environment.systemPackages = with pkgs; [];

  # Allow users to use zsh shell
  programs.zsh.enable = true;
  environment.shells = with pkgs; [ zsh ];
  # Support completion for system packages
  # Ref: https://nix-community.github.io/home-manager/options.html#opt-programs.zsh.enableCompletion
  environment.pathsToLink = [ "/share/zsh" ];

  # Support user desktops
  xdg.portal = {
    enable = true;
    # allow screen sharing with wlroots compositors
    wlr.enable = true;
  #  extraPortals = with pkgs; [
  #    xdg-desktop-portal-wlr
  #    xdg-desktop-portal-gtk
  #  ];
  };

  # video support
  hardware = {
    opengl = {
      enable = true;
    };
  };

  # audio
  security.rtkit.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    hyshka = {
      isNormalUser = true;
      initialPassword = "pw123";
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCTi8LybJv9rM1PY+89RizysnNS0qe17peP1lsribcY+VuEW1aZrjYePJKVyFlIUqQnPGr9zK2FsLqU+Y40hfNQMITlHQMCbrWLvGdPvR2uP17+DFvZSp+ox0KVIjqOgxpLIWbszHKzfA1g8FJfzpH7j1kzP7bEonUXAGd3eVtf2kuzELKl7pI4uQyuoKF6ti1EMKQEOivLJm9aphz8/Bk+aZVgFy2srCxhqpWM5v967iNOK+UtPAqStrkJTvc1NtmMe6YQ099lRltq5dLerBfb0r5BdTKa+oTrgMELzV1YOv1i5Nj21RUz0kDT1eiVoqmyYAIlB8Rn01qByCU+2FH1 bryan@hyshka.com"
      ];
      extraGroups = [
        "wheel"
        "video"
        "audio"
      ] ++ ifTheyExist [
        "docker"
      ];
      shell = pkgs.zsh;
    };
  };

  # Support Sway window manager
  programs.sway = {
    enable = true;
  };

  # autostart sway on login
  environment.loginShellInit = ''
    if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec sway -d >> sway.log 2>&1
    fi
  '';

  # Support Docker
  virtualisation.docker = {
    enable = true;
  };

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    # Obfuscate port
    ports = [ 38001 ];
    # Forbid root login through SSH.
    permitRootLogin = "no";
    # Use keys only. Remove if you want to SSH using password (not recommended)
    passwordAuthentication = false;
  };
  # Passwordless sudo when SSH'ing with keys
  security.pam.enableSSHAgentAuth = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "22.11";
}

