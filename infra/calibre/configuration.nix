{
  config,
  lib,
  pkgs,
  ...
}:
let
  library = "/mnt/books";
in
{
  # No /persist volume; the base image's fake mount would fail without one.
  fileSystems."/persist".enable = lib.mkForce false;
  environment.persistence."/persist".directories = lib.mkForce [ ];

  # Calibre keeps its own uid and joins the shared mediacenter group (gid 13000),
  # matching jellyfin and pinchflat. The host tree is 1000:13000 775; group write
  # is what grants access, ownership is irrelevant.

  # To generate user db:
  # 1. Run calibre-server with auth disabled
  # 2. Then, generate a users database:
  #    calibre-server --userdb ./calibre-users.sqlite --manage-users
  # 3. Finally, encrypt the binary as a secret:
  #    sops -e ./calibre-users.sqlite > infra/calibre/secrets/calibre-users.sqlite

  users.users.calibre-server.isSystemUser = true;
  users.groups.mediacenter.gid = 13000;

  sops.secrets."calibre-users.sqlite" = {
    sopsFile = ./secrets/calibre-users.sqlite;
    format = "binary";
    owner = config.services.calibre-server.user;
    group = config.services.calibre-server.group;
  };

  # force enable fonts for calibre import HTML fallback
  fonts.fontconfig.enable = lib.mkForce true;
  environment.systemPackages = [ pkgs.dejavu_fonts ];

  services.calibre-server = {
    enable = true;
    port = 8083;
    openFirewall = true;
    host = "0.0.0.0";
    group = "mediacenter";
    auth = {
      mode = "basic";
      enable = true;
      userDb = config.sops.secrets."calibre-users.sqlite".path;
    };
    libraries = [
      library
    ];
  };
  systemd.services.calibre-server.serviceConfig.UMask = "0002";

  # watches the synced ebook folder and automatically loads it into calibre
  systemd.paths.calibre-watch = {
    description = "Watch ebooks folder";
    pathConfig = {
      PathChanged = library;
    };
    wantedBy = [ "default.target" ];
  };

  systemd.services.calibre-watch = {
    description = "Import ebook library into Calibre library";
    serviceConfig = {
      Type = "oneshot";
      User = "calibre-server";
      Group = "mediacenter";
      UMask = "0002";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      ExecStart = "${pkgs.calibre}/bin/calibredb add ${library} --recurse --library-path=${library} --automerge=overwrite";
    };
  };
}
