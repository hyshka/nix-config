{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/users/hyshka

    ../common/optional/android.nix
    ../common/optional/input-leap.nix
    ../common/optional/pipewire.nix
    ../common/optional/plasma.nix
    ../common/optional/powertop.nix
    ../common/optional/wireless.nix
  ];

  networking.hostName = "ashyn";

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

  # https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "24.05";
}
