{
  pkgs,
  config,
  lib,
  ...
}: let
  isLinux = pkgs.stdenv.isLinux;
  pinentry =
    if builtins.hasAttr "plasma" config.programs && config.programs.plasma.enable
    then {
      package = pkgs.pinentry-qt;
    }
    else {
      package = pkgs.pinentry-curses;
    };
in {
  services.gpg-agent = lib.mkIf isLinux {
    enable = true;
    pinentryPackage = pinentry.package;
    defaultCacheTtl = 1800; # 30 min
    defaultCacheTtlSsh = 1800; # 30 min
  };

  programs.gpg.enable = true;
}
