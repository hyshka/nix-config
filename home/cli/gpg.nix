{
  pkgs,
  config,
  ...
}:
let
  isLinux = pkgs.stdenv.isLinux;
  pinentry =
    if !isLinux then
      {
        package = pkgs.pinentry_mac;
      }
    else if builtins.hasAttr "plasma" config.programs && config.programs.plasma.enable then
      {
        package = pkgs.pinentry-qt;
      }
    else
      {
        package = pkgs.pinentry-curses;
      };
in
{
  services.gpg-agent = {
    enable = true;
    pinentry.package = pinentry.package;
    defaultCacheTtl = 1800; # 30 min
    defaultCacheTtlSsh = 1800; # 30 min
  };

  programs.gpg.enable = true;
}
