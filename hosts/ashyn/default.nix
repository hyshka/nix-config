{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/users/hyshka

    ../common/optional/android.nix
  ];

  # Chromebook nixos references
  # Custom audio scripts
  # - https://github.com/ChocolateLoverRaj/nixos-system-config/blob/43ca84bd1440473a388a633bd1bd0ca1f3fee2e8/chromebook-audio.nix#L5
  # - https://github.com/baduhai/nix-config/blob/6a000a2a460ab01213d744ad294ba57f6c69ad7e/hosts/desktops/io.nix#L4
  # Charge control
  # - https://github.com/ChocolateLoverRaj/nixos-system-config/blob/43ca84bd1440473a388a633bd1bd0ca1f3fee2e8/auto-stop-charging.nix
  # - https://github.com/ChocolateLoverRaj/nixos-system-config/blob/43ca84bd1440473a388a633bd1bd0ca1f3fee2e8/stop-charging-before-suspend.nix
  # ectool pkg
  # - https://github.com/ChocolateLoverRaj/nixos-system-config/blob/43ca84bd1440473a388a633bd1bd0ca1f3fee2e8/cros-ectool.nix
  # webcam
  # - https://github.com/ChocolateLoverRaj/nixos-system-config/blob/43ca84bd1440473a388a633bd1bd0ca1f3fee2e8/external-camera.nix

  # TODO: move to modules
  # KDE
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.defaultSession = "plasma";
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = [pkgs.kdePackages.konsole];
  # Make Firefox use the KDE file picker.
  # Preferences source: https://wiki.archlinux.org/title/firefox#KDE_integration
  programs.firefox = {
    enable = true;
    preferences = {
      "widget.use-xdg-desktop-portal.file-picker" = 1;
    };
  };
  # TODO: krohnkite Kwin script
  # TODO krohnkite key binds

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
  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override {enableHybridCodec = true;};
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      # this is for jasper lake
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libvdpau-va-gl
    ];
  };
  environment.sessionVariables = {LIBVA_DRIVER_NAME = "iHD";}; # Force intel-media-driver

  # Screen sharing under wayland
  programs.firefox.package = pkgs.wrapFirefox (pkgs.firefox-devedition-unwrapped.override {pipewireSupport = true;}) {};
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };
  };
  # TODO: sway
  # https://nixos.wiki/wiki/Firefox#Screen_Sharing_under_Wayland

  # Power management
  powerManagement.powertop.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Synergy
  # TODO: migrate to Deskflow: https://github.com/NixOS/nixpkgs/pull/346698
  services.synergy.server = {
    enable = false;
    # The port overrides the default port, 24800.
    address = "10.0.0.230";
    screenName = "ashyn";
    configFile = pkgs.writeText "synergy.conf" ''
      section: screens
          macbook:
          ashyn:
      end

      section: links
          ashyn:
              left = macbook
          macbook:
              right = ashyn
      end

      section: options
          keystroke(control+super+right) = switchInDirection(right)
          keystroke(control+super+left) = switchInDirection(left)
      end
    '';
    # TODO tls requires product key
    # tls.enable = false;
  };
  # TODO: try input-leap
  # https://github.com/NixOS/nixpkgs/pull/341425
  environment.systemPackages = [pkgs.input-leap];
  networking.firewall.allowedTCPPorts = [24800];

  # Keyboard
  # Galtic is a 105 key ISO layout
  # Visual layout with gkbd-keyboard-display application from libgnomekbd
  # Test keyboard with: sudo keyd monitor
  # Config references:
  # - https://github.com/baduhai/nix-config/blob/6a000a2a460ab01213d744ad294ba57f6c69ad7e/hosts/desktops/io.nix#L67
  # - https://wiki.archlinux.org/title/Chrome_OS_devices#Hotkeys
  # - https://github.com/WeirdTreeThing/cros-keyboard-map
  services.keyd = {
    enable = true;
    # Keyboard sends back, forward, etc. instead of f1, f2, etc.
    keyboards.chromebook = {
      ids = ["0001:0001"];
      settings = {
        # Chromebook function keys
        main = {
          # meta triggers esc, when held trigger meta
          meta = "overload(meta, esc)";
          # TODO: Weird extra key beside left shift
          "102nd" = "layer(shift)";

          # TODO: tweak these to be more useful
          #refresh = "f5";
          #zoom = "M-f11";
          #scale = "M-w";
        };
        shift = {
          meta = "capslock";
        };
        # Allow F1-10 access through meta+fnX
        # Allow TTY access, ex. ctrl+alt+meta+back == ctrl+alt+f1
        meta = {
          back = "f1";
          forward = "f2";
          refresh = "f3";
          zoom = "f4";
          scale = "f5";
          brightnessdown = "f6";
          brightnessup = "f7";
          mute = "f8";
          volumedown = "f9";
          volumeup = "f10";

          left = "home";
          right = "end";
          up = "pageup";
          down = "pagedown";
        };
        "alt" = {
          backspace = "delete";
          # My keyboard doesn't have a backlight, but this is a good reference
          # brightnessdown = "kbdillumdown";
          # brightnessup = "kbdillumup";
          # f6 = "kbdillumdown";
          # f7 = "kbdillumup";
        };
        "control" = {
          f5 = "sysrq";
          scale = "sysrq";
        };
        "control+alt" = {
          backspace = "C-A-delete";
        };
      };
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  networking.hostName = "ashyn";

  # https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "24.05";
}
