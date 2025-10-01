{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  home.packages = with pkgs; [
    kdePackages.plasma-disks
    kdePackages.krohnkite
    kwin6-bismuth-decoration
  ];

  # plasma-manager
  # https://github.com/nix-community/plasma-manager
  # https://nix-community.github.io/plasma-manager/options.xhtml

  # https://github.com/phrmendes/dotfiles/blob/0deb7f64e88c165e2a3db8bdf7491dc45209c8d6/modules/plasma.nix#L10
  # https://github.com/taj-ny/nix-config/blob/654491b314526e4d319aae5d2daaea09c8159bf2/home/config/_shared/programs/plasma/shortcuts.nix#L39

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
        # TODO: only for ashyn
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
    panels = [
      {
        location = "top";
        screen = "all";
        widgets = [
          "org.kde.plasma.pager"
          "org.kde.plasma.icontasks"
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
        ];
      }
    ];
    shortcuts = {
      kwin = {
        "Kill Window" = "Alt+Shift+Q";
        # Desktops
        "Switch to Desktop 1" = "Alt+1";
        "Switch to Desktop 2" = "Alt+2";
        "Switch to Desktop 3" = "Alt+3";
        "Switch to Desktop 4" = "Alt+4";
        "Switch to Desktop 5" = "Alt+5";
        "Window to Desktop 1" = "Alt+!";
        "Window to Desktop 2" = "Alt+@";
        "Window to Desktop 3" = "Alt+#";
        "Window to Desktop 4" = "Alt+$";
        "Window to Desktop 5" = "Alt+%";
        "Show Desktop" = "none";
        # Krohnkite
        # TODO krohnkite key binds
        # https://github.com/phrmendes/dotfiles/blob/0deb7f64e88c165e2a3db8bdf7491dc45209c8d6/modules/plasma.nix#L4
        # https://github.com/f-koehler/nix-configs/blob/3f346f598c5dab55cdb6fc42a067c705fb91ec9b/home/modules/plasma.nix#L8
        "KrohnkiteColumnsLayout" = "Alt+Shift+C";
        "KrohnkiteMonocleLayout" = "Alt+Shift+M";
        "KrohnkiteStackedLayout" = "Alt+Shift+S";
        "KrohnkiteFloatAll" = "Alt+Shift+F";
        "KrohnkiteFocusDown" = "Alt+J";
        "KrohnkiteFocusLeft" = "Alt+H";
        "KrohnkiteFocusRight" = "Alt+L";
        "KrohnkiteFocusUp" = "Alt+K";
        "KrohnkiteGrowHeight" = "Alt++";
        "KrohnkiteGrowWidth" = "Alt+=";
        "KrohnkiteNextLayout" = "Alt+]";
        "KrohnkitePreviousLayout" = "Alt+[";
        "KrohnkiteRotate" = "Alt+R";
        "KrohnkiteSetMaster" = "Alt+M";
        "KrohnkiteShiftDown" = "Alt+Shift+J";
        "KrohnkiteShiftLeft" = "Alt+Shift+H";
        "KrohnkiteShiftRight" = "Alt+Shift+L";
        "KrohnkiteShiftUp" = "Alt+Shift+K";
        "KrohnkiteShrinkHeight" = "Alt+_";
        "KrohnkiteShrinkWidth" = "Alt+-";
        "KrohnkiteToggleFloat" = "Alt+F";
        "KrohnkiteDecrease" = "Alt+D";
        "KrohnkiteIncrease" = "Alt+I";
      };
      plasmashell."show-on-mouse-pos" = [ "Meta+Shift+C" ];
    };
    spectacle.shortcuts.captureRectangularRegion = "Ctrl+Alt+P";
    hotkeys.commands."launch-alacritty" = {
      name = "Launch alacritty";
      key = "Alt+Return";
      command = "alacritty";
    };
    hotkeys.commands."launch-krunner" = {
      name = "Launch krunner";
      key = "Meta+Space";
      command = "krunner";
    };
    configFile = {
      "kcminputrc"."Libinput/1267/276/Elan Touchpad"."ScrollFactor" = 0.3;
      "kdeglobals"."General"."TerminalApplication" = "alacritty";
      "kdeglobals"."General"."TerminalService" = "Alacritty.desktop";
      "kwinrc"."Plugins"."krohnkiteEnabled" = true;
      "kwinrc"."Script-krohnkite"."ignoreClass" =
        "krunner,yakuake,spectacle,kded5,xwaylandvideobridge,plasmashell,ksplashqml,org.kde.plasmashell,org.kde.polkit-kde-authentication-agent-1,org.kde.kruler,kruler,gamescope";
      "plasma-localerc"."Formats"."LANG" = "en_US.UTF-8";
      "plasmanotifyrc"."Notifications"."PopupTimeout" = 3000;
      "spectaclerc"."GuiConfig"."captureDelay" = 3;
      "spectaclerc"."GuiConfig"."captureMode" = 0;
      # TODO krohnkite config
      # https://github.com/taj-ny/nix-config/blob/654491b314526e4d319aae5d2daaea09c8159bf2/home/config/_shared/programs/plasma/kwin/krohnkite.nix
      # https://github.com/phrmendes/dotfiles/blob/0deb7f64e88c165e2a3db8bdf7491dc45209c8d6/modules/plasma.nix#L119
      #"Script-krohnkite" = {
      #    "enableBTreeLayout" = true;
      #    "enableQuarterLayout" = true;
      #    "enableStackedLayout" = true;
      #};
    };
  };
}
