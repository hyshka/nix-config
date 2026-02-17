{
  # Ref:
  # - https://daiderd.com/nix-darwin/manual/index.html
  # - https://github.com/ryan4yin/nix-darwin-kickstarter/blob/main/rich-demo/modules/system.nix
  # https://github.com/LnL7/nix-darwin/blob/master/modules/examples/lnl.nix

  system = {
    primaryUser = "hyshka";

    # activationScripts are executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.
    activationScripts.postActivation.text = ''
      # activateSettings -u will reload the settings from the database and apply them to the current session,
      # so we do not need to logout and login again to make the changes take effect.
      sudo -u hyshka /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    defaults = {
      # Match mouse acceleration to Linux
      ".GlobalPreferences"."com.apple.mouse.scaling" = 1.0;

      menuExtraClock.Show24Hour = true;

      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
        dashboard-in-overlay = true;
        expose-group-apps = true; # For Aerospace
        show-recents = false;
        launchanim = false;
        mru-spaces = false;
        static-only = true;
        # Disable hot corners
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
        wvous-br-corner = 1;
      };

      finder = {
        _FXShowPosixPathInTitle = true;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        FXEnableExtensionChangeWarning = false;
        FXDefaultSearchScope = "SCcf"; # Search current folder by default
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };

      NSGlobalDomain = {
        AppleICUForce24HourTime = true;
        "com.apple.swipescrolldirection" = false;
        "com.apple.sound.beep.feedback" = 0;
        AppleFontSmoothing = 0;
        AppleInterfaceStyle = null; # Force light mode
        AppleKeyboardUIMode = 3;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;

        # Keyboard timing configuration (keyboard-centric improvements)
        # Keyboard repeat rate (1 = fastest, 15ms between repeats)
        KeyRepeat = 1;
        # Initial key repeat delay (10 = shortest, 150ms)
        InitialKeyRepeat = 10;
        # Disable press-and-hold for special characters (essential for vim)
        ApplePressAndHoldEnabled = false;

        # Use F1-F12 as standard function keys (no Fn modifier needed)
        "com.apple.keyboard.fnState" = true;
      };

      # Customize settings that not supported by nix-darwin directly
      # see the source code of this project to get more undocumented options:
      #    https://github.com/rgcr/m-cli
      #
      # All custom entries can be found by running `defaults read` command.
      # or `defaults read xxx` to read a specific domain.
      CustomUserPreferences = {
        ".GlobalPreferences" = {
          # automatically switch to a new space when switching to the application
          AppleSpacesSwitchOnActivate = true;
        };
        NSGlobalDomain = {
          # Add a context menu item for showing the Web Inspector in web views
          WebKitDeveloperExtras = true;
        };
        "com.apple.finder" = {
          ShowExternalHardDrivesOnDesktop = true;
          ShowHardDrivesOnDesktop = true;
          ShowMountedServersOnDesktop = true;
          ShowRemovableMediaOnDesktop = true;
          _FXSortFoldersFirst = true;
          # When performing a search, search the current folder by default
          FXDefaultSearchScope = "SCcf";
        };
        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
        # Prevent Photos from opening automatically when devices are plugged in
        "com.apple.ImageCapture".disableHotPlug = true;

        # Disable Mission Control shortcuts (conflicts with Aerospace)
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            # Disable Mission Control (Ctrl+Up)
            "32" = {
              enabled = false;
            };
            "34" = {
              enabled = false;
            };
            # Disable Application Windows (Ctrl+Down)
            "33" = {
              enabled = false;
            };
            "35" = {
              enabled = false;
            };
            # Disable Show Desktop
            "36" = {
              enabled = false;
            };
            "37" = {
              enabled = false;
            };
            # Disable Spotlight (Command-Space)
            "64" = {
              enabled = false;
            };
            "65" = {
              enabled = false;
            };
          };
        };

        # Show date in menu bar (helpful for keyboard users who hide dock)
        "com.apple.menuextra.clock" = {
          ShowDate = 1;
        };
      };

      loginwindow = {
        GuestEnabled = false;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };
}
