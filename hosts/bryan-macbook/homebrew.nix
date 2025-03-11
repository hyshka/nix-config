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
      "deskflow/homebrew-tap" # deskflow
    ];

    # `brew install`
    brews = [
      "helm"
    ];

    # `brew install --cask`
    casks = [
      # TODO: config https://github.com/AlexNabokikh/nix-config/blob/master/home/modules/darwin-aerospace.nix
      "aerospace" # tiling window manager, https://nikitabobko.github.io/AeroSpace/guide#installation
      "raycast" # (HotKey: alt/option + space)search, caculate and run scripts(with many plugins), https://www.raycast.com/
      "tomatobar"
      "espanso"
      "languagetool"
      "firefox"
      "slack"
      "obs"
      "handbrake"
      "libreoffice"
      "1password"
      "openvpn-connect"
      "fontforge"
      "orbstack"
    ];
  };

  # TODO espanso: mac not supported by home-manager module
  # TODO set content of config file in nix
  # /Users/hyshka/Library/Application Support/espanso/config/default.yml
  # /Users/hyshka/Library/Application Support/espanso/match/base.yml
  # https://github.com/nix-community/home-manager/blob/master/modules/services/espanso.nix#L103
}
