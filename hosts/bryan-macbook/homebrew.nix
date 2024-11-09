{
  # TODO To make this work, homebrew need to be installed manually, see https://brew.sh
  # The apps installed by homebrew are not managed by nix, and not reproducible!
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      # 'zap': uninstalls all formulae(and related files) not listed here.
      cleanup = "zap";
    };

    taps = [
      "homebrew/cask-fonts"
      "homebrew/services"
      "homebrew/cask-versions"
      "nikitabobko/tap" # aerospace
    ];

    # `brew install`
    brews = [
      "wget"
      "curl" # do not install curl via nixpkgs, it's not working well on macOS!

      # work tools
      "helm" # not available for darwin in nixpkgs
    ];

    # `brew install --cask`
    casks = [
      # productivity
      # TODO: config https://github.com/AlexNabokikh/nix-config/blob/master/home/modules/darwin-aerospace.nix
      "aerospace" # tiling window manager, https://nikitabobko.github.io/AeroSpace/guide#installation
      "raycast" # (HotKey: alt/option + space)search, caculate and run scripts(with many plugins), https://www.raycast.com/
      "tomatobar" # pomodoro timer
      #"betterdisplay" # display manager
      "espanso" # text expander
      "languagetool"

      # mine
      "spotify"

      # work tools
      "firefox"
      "google-chrome"
      "arc"
      "slack"
      "obs"
      "handbrake"
      "libreoffice"
      "1password"
      "openvpn-connect" # VPN
      "fontforge"
      # TODO zoom managed by work
      #"zoom"
      # TODO mac not supported by home-manager module
      # TODO set content of config file in nix
      # /Users/hyshka/Library/Application Support/espanso/config/default.yml
      # /Users/hyshka/Library/Application Support/espanso/match/base.yml
      # https://github.com/nix-community/home-manager/blob/master/modules/services/espanso.nix#L103

      # Docker
      # Manually open docker desktop:
      #   - Use advanced settings > user install so you don't need to sudo docker
      # client commands.
      # then open settings:
      #   - disable start at login
      #   - 16 gb memory
      #   - use rosetta
      # The following was noted but not required for me:
      #   - add $HOME/.docker/bin to your PATH
      #"docker"
      "orbstack"
    ];
  };
}
