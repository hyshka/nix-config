{ ... }: {
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
      "homebrew/cask"
      "homebrew/cask-fonts"
      "homebrew/services"
      "homebrew/cask-versions"
    ];

    # `brew install`
    # TODO Feel free to add your favorite apps here.
    brews = [
      "wget"  # download tool
      "curl"  # no not install curl via nixpkgs, it's not working well on macOS!

      # muck rack
      #"pre-commit"
    ];

    # `brew install --cask`
    # TODO Feel free to add your favorite apps here.
    casks = [
      "firefox"
      "google-chrome"
      "slack"
      "discord"
      "spotify"
      #"discord"
      #"syncthing"
      #"raycast"   # (HotKey: alt/option + space)search, caculate and run scripts(with many plugins)
      #"iglance"   # beautiful system monitor
      "tomatobar"

      # muck rack
      "docker"
      # Manually open docker desktop:
      #   - Use advanced settings > user install so you don't need to sudo docker
      # client commands.
      # then open settings:
      #   - disable start at login
      #   - 16 gb memory
      #   - use rosetta
      # The following was noted but not required for me:
      #   - add $HOME/.docker/bin to your PATH
    ];
  };
}
