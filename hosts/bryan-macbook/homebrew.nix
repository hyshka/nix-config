{...}: {
  # TODO To make this work, homebrew need to be installed manually, see https://brew.sh
  #
  # The apps installed by homebrew are not managed by nix, and not reproducible!
  # But on macOS, homebrew has a much larger selection of apps than nixpkgs, especially for GUI apps!
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      # 'zap': uninstalls all formulae(and related files) not listed here.
      cleanup = "zap";
    };

    # Applications to install from Mac App Store using mas.
    # You need to install all these Apps manually first so that your apple account have records for them.
    # otherwise Apple Store will refuse to install them.
    # For details, see https://github.com/mas-cli/mas
    masApps = {
      # TODO Feel free to add your favorite apps here.
      #Xcode = 497799835;
      #Slack = TODO;
      #Zoom = TODO;
    };

    taps = [
      "homebrew/cask-fonts"
      "homebrew/services"
      "homebrew/cask-versions"
      "nikitabobko/tap" # aerospace
    ];

    # `brew install`
    brews = [
      "wget" # download tool
      "curl" # no not install curl via nixpkgs, it's not working well on macOS!

      # work tools
      "helm" # not available for darwin in nixpkgs
    ];

    # `brew install --cask`
    casks = [
      # productivity
      "amethyst" # tiling window manager
      "aerospace" # tiling window manager, https://nikitabobko.github.io/AeroSpace/guide#installation
      "raycast" # (HotKey: alt/option + space)search, caculate and run scripts(with many plugins), https://www.raycast.com/
      "tomatobar" # pomodoro timer
      "betterdisplay" # display manager
      "espanso" # text expander
      "languagetool"
      # TODO window sizing shortcuts
      #"rectangle" # https://rectangleapp.com/

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
      #"syncthing"
      #"iglance"   # beautiful system monitor
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
