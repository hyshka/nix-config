{pkgs, ...}: {
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.defaultSession = "plasma";
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = [
    pkgs.kdePackages.elisa
    pkgs.kdePackages.kate
    pkgs.kdePackages.khelpcenter
    pkgs.kdePackages.konsole
  ];
  # Make Firefox use the KDE file picker.
  # Preferences source: https://wiki.archlinux.org/title/firefox#KDE_integration
  programs.firefox = {
    enable = true;
    preferences = {
      "widget.use-xdg-desktop-portal.file-picker" = 1;
    };
  };
  # TODO: move to home packages
  environment.systemPackages = with pkgs; [
    kdePackages.krohnkite
    kwin6-bismuth-decoration
  ];
  # TODO plasma-manager
  # https://github.com/nix-community/plasma-manager
  # TODO krohnkite key binds
  # https://github.com/phrmendes/dotfiles/blob/0deb7f64e88c165e2a3db8bdf7491dc45209c8d6/modules/plasma.nix#L4
  # https://github.com/f-koehler/nix-configs/blob/3f346f598c5dab55cdb6fc42a067c705fb91ec9b/home/modules/plasma.nix#L8

  # Screen sharing under wayland
  # TODO: sway https://nixos.wiki/wiki/Firefox#Screen_Sharing_under_Wayland
  programs.firefox.package = pkgs.wrapFirefox (pkgs.firefox-devedition-unwrapped.override {pipewireSupport = true;}) {};
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };
  };
}
