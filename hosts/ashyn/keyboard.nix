{
  # Galtic is a 105 key ISO layout
  # Visual layout with gkbd-keyboard-display application from libgnomekbd
  # Test keyboard with: sudo keyd monitor
  # Config references:
  # - https://github.com/baduhai/nix-config/blob/6a000a2a460ab01213d744ad294ba57f6c69ad7e/hosts/desktops/io.nix#L67
  # - https://wiki.archlinux.org/title/Chrome_OS_devices#Hotkeys
  # - https://github.com/WeirdTreeThing/cros-keyboard-map
  # - https://github.com/eli-sauvage/dotfiles/blob/main/machines/chromebook/keyd.nix
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
}
