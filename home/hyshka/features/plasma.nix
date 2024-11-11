{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];

  home.packages = with pkgs; [
    kdePackages.krohnkite
    kwin6-bismuth-decoration
  ];

  # TODO plasma-manager
  # https://github.com/nix-community/plasma-manager
  # TODO krohnkite key binds
  # https://github.com/phrmendes/dotfiles/blob/0deb7f64e88c165e2a3db8bdf7491dc45209c8d6/modules/plasma.nix#L4
  # https://github.com/f-koehler/nix-configs/blob/3f346f598c5dab55cdb6fc42a067c705fb91ec9b/home/modules/plasma.nix#L8

  # https://github.com/phrmendes/dotfiles/blob/0deb7f64e88c165e2a3db8bdf7491dc45209c8d6/modules/plasma.nix#L10
  # https://github.com/taj-ny/nix-config/blob/654491b314526e4d319aae5d2daaea09c8159bf2/home/config/_shared/programs/plasma/shortcuts.nix#L39

  # krohnkite config
  # https://github.com/taj-ny/nix-config/blob/654491b314526e4d319aae5d2daaea09c8159bf2/home/config/_shared/programs/plasma/kwin/krohnkite.nix
  # https://github.com/phrmendes/dotfiles/blob/0deb7f64e88c165e2a3db8bdf7491dc45209c8d6/modules/plasma.nix#L119

  programs.plasma = {
    enable = true;
    overrideConfig = true;
    workspace = {
      wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Mountain/contents/images/5120x2880.png";
    };
    kscreenlocker = {
      lockOnResume = true;
      timeout = lib.mkDefault 5; # TODO different for Starship
      appearance = {
        wallpaper = config.programs.plasma.workspace.wallpaper;
      };
    };
    input = {
      keyboard.model = lib.mkDefault "pc105"; # TODO different for Starship
      mice = [
        #"kcminputrc"."Libinput/1133/16500/Logitech G305"."PointerAcceleration" = "-0.800";
        {
          acceleration = -0.8;
          enable = true;
          name = "Logitech G305";
          productId = "16500";
          vendorId = "1133";
        }
      ];
      touchpads = [
        {
          enable = true;
          rightClickMethod = "twoFingers";
          scrollMethod = "twoFingers";
          name = "Elan Touchpad";
          productId = "276";
          vendorId = "1267";
        }
      ];
    };
    kwin = {
      virtualDesktops.number = 5;
      effects = {
        minimization.animation = "off";
        desktopSwitching.animation = "off";
      };
    };
    shortcuts = {
      kwin = {
        "Kill Window" = "Alt+Shift+Q";
        # Desktops
        "Switch to Desktop 1" = "Alt+1";
        "Switch to Desktop 2" = "Alt+2";
        "Switch to Desktop 3" = "Alt+3";
        "Switch to Desktop 4" = "Alt+4";
        "Window to Desktop 1" = "Alt+Shift+1";
        "Window to Desktop 2" = "Alt+Shift+2";
        "Window to Desktop 3" = "Alt+Shift+3";
        "Window to Desktop 4" = "Alt+Shift+4";
        "Show Desktop" = "none";
        # Krohnkite
        "KrohnkiteColumnsLayout" = "Alt+Shift+C";
        "KrohnkiteFocusDown" = "Alt+J";
        "KrohnkiteFocusLeft" = "Alt+H";
        "KrohnkiteFocusRight" = "Alt+L";
        "KrohnkiteFocusUp" = "Alt+K";
        "KrohnkiteIncrease" = "Alt+Shift+I";
        "KrohnkiteMonocleLayout" = "Alt+Shift+M";
        "KrohnkiteShiftDown" = "Alt+Shift+J";
        "KrohnkiteShiftLeft" = "Alt+Shift+H";
        "KrohnkiteShiftRight" = "Alt+Shift+L";
        "KrohnkiteShiftUp" = "Alt+Shift+K";
        "KrohnkiteStackedLayout" = "Alt+Shift+S";
        "KrohnkiteToggleFloat" = "Alt+Shift+Space";
      };
    };
    spectacle.shortcuts.captureRectangularRegion = "Ctrl+Alt+P";
    hotkeys.commands."launch-alacritty" = {
      name = "Launch alacritty";
      key = "Alt+Return";
      command = "alacritty";
    };
    hotkeys.commands."launch-krunner" = {
      name = "Launch krunner";
      key = "Alt+Space";
      command = "krunner";
    };
    configFile = {
      "kcminputrc"."Libinput/1267/276/Elan Touchpad"."ScrollFactor" = 0.3;
      "kdeglobals"."General"."TerminalApplication" = "alacritty";
      "kdeglobals"."General"."TerminalService" = "Alacritty.desktop";
      "kwinrc"."Plugins"."krohnkiteEnabled" = true;
      "plasma-localerc"."Formats"."LANG" = "en_US.UTF-8";
      "plasmanotifyrc"."Notifications"."PopupTimeout" = 3000;
      "spectaclerc"."GuiConfig"."captureDelay" = 3;
      "spectaclerc"."GuiConfig"."captureMode" = 0;
    };
  };
}
