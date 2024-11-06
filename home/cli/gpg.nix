{
  pkgs,
  config,
  lib,
  ...
}: let
  isLinux = pkgs.stdenv.isLinux;
  #pinentry =
  #  if config.gtk.enable then {
  #    packages = [ pkgs.pinentry-gnome pkgs.gcr ];
  #    name = "gnome3";
  #  } else {
  #    packages = [ pkgs.pinentry-curses ];
  #    name = "curses";
  #  };
  pinentry = {
    packages = [pkgs.pinentry-curses];
    name = "curses";
  };
in {
  # TODO remove?
  home.packages = pinentry.packages;

  services.gpg-agent = lib.mkIf isLinux {
    enable = true;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-curses;
    defaultCacheTtl = 1800; # 30 min
    defaultCacheTtlSsh = 1800; # 30 min
  };

  programs.gpg.enable = true;
}
