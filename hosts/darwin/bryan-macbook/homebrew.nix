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
      "nikitabobko/tap" # aerospace
    ];

    # `brew install`
    brews = [
      "helm"
    ];

    # `brew install --cask`
    casks = [
      # TODO: aerospace config
      # https://nix-darwin.github.io/nix-darwin/manual/index.html#opt-services.aerospace.enable
      # https://github.com/AlexNabokikh/nix-config/blob/master/home/modules/darwin-aerospace.nix
      "aerospace" # tiling window manager, https://nikitabobko.github.io/AeroSpace/guide#installation
      "raycast" # (HotKey: alt/option + space)search, caculate and run scripts(with many plugins), https://www.raycast.com/
      "shottr" # Free screenshot tool with OCR and annotation
      "tomatobar"
      "espanso"
      "languagetool-desktop"
      "slack"
      "obs"
      "handbrake-app"
      "1password"
      "openvpn-connect"
      "fontforge-app"
      "orbstack"
      "brave-browser"
      "caffeine"
      "spotify"
    ];
  };

  # TODO espanso: mac not supported by home-manager module
  # TODO set content of config file in nix
  # /Users/hyshka/Library/Application Support/espanso/config/default.yml
  # /Users/hyshka/Library/Application Support/espanso/match/base.yml
  # https://github.com/nix-community/home-manager/blob/master/modules/services/espanso.nix#L103
}
