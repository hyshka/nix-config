{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./font.nix
    ./gtk.nix
    ./qt.nix
    #./xdg.nix
    ./espanso.nix
    #./sway.nix
    ./i3.nix
  ];

  # TODO move to module
  xdg = {
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = ["firefox-devedition.desktop"];
        "text/xml" = ["firefox-devedition.desktop"];
        "x-scheme-handler/http" = ["firefox-devedition.desktop"];
        "x-scheme-handler/https" = ["firefox-devedition.desktop"];
      };
    };
  };

  home.packages = with pkgs; [
    # web
    firefox-devedition-bin
    ungoogled-chromium

    # comms
    discord
    slack
    zoom-us # TODO can't sign in but can join video from zoom links

    # imaging
    ansel
    vkdt # TODO
    unstable.darktable
    hugin
    inkscape-with-extensions
    gimp-with-plugins
    digikam
    imv

    # video
    jellyfin-media-player
    mpv
    handbrake
    obs-studio
    flowblade # TODO won't launch

    # office
    libreoffice
    zathura

    # file management
    xfce.thunar
    xfce.thunar-volman # requires gvfs
    xfce.thunar-archive-plugin

    # networking
    unstable.mullvad-vpn
    transmission-gtk

    # music
    spotify

    # gaming
    #etlegacy # can't install 32 bit version on 64 bit OS for TC:E
    unstable.yuzu-mainline
    unstable.gzdoom
    lutris

    # misc
    yubikey-manager
    corectrl
    gparted
    xorg.xhost # required by gparted
    heimdall
    sway-contrib.grimshot # screenshots
    flameshot # screenshots
    grim # required for flameshot
    pavucontrol # volume controls
    xdg-utils # to fix programs launching other programs
    pkgs.unstable.uair # pomodoro timer
    libnotify # required to send notifications from uair to mako
    gnome.pomodoro

    # work
    fontforge-gtk
    zeal
    # work build deps
    # TODO move to module
    gnumake
    awscli2
    pre-commit
    python310Packages.nodeenv # for node.js pre-commit hooks
  ];

  xdg.configFile = {
    "uair" = {
      text = ''
        [defaults]
        format = "{time}\n"

        [[sessions]]
        id = "work"
        name = "Work"
        duration = "50m"
        command = "notify-send 'Work Done!'"

        [[sessions]]
        id = "rest"
        name = "Rest"
        duration = "10m"
        command = "notify-send 'Rest Done!'"
      '';
      target = "uair/uair.toml";
    };
  };

  # Enable font discovery
  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    LIBSEAT_BACKEND = "logind";
    TERMINAL = "kitty -1";
    BROWSER = "firefox-devedition";
  };

  services.clipman.enable = true;
  #services.udiskie.enable = true;

  programs.kitty = {
    enable = true;
    font = {
      size = 11;
      name = config.fontProfiles.monospace.family;
    };
    settings = {
      scrollback_lines = 0;
      scrollback_pager_history_size = 0;
      #detect_urls = "yes";
      input_delay = 0;
      enable_audio_bell = "no";
    };
  };
}
