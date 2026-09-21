{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  container = import ./default.nix { inherit lib inputs; };
  library = "/mnt/books";
in
{
  imports = [ (container.mkContainer { name = "calibre"; }) ];

  # Unique set up:
  # - Set raw.idmap: incus config set calibre raw.idmap='uid 1000-1000 213-213\ngid 13000-13000 213-213'
  # - On the host, add root:1000:213 to /etc/subuid and root:13000:213 to /etc/subgid to allow Incus to perform the idmapping

  # To generate user db:
  # 1. Run calibre-server with auth disabled
  # 2. Then, generate a users database:
  #    calibre-server --userdb ./calibre-users.sqlite --manage-users
  # 3. Finally, encrypt the binary as a secret:
  #    sops -e ./calibre-users.sqlite > containers/secrets/calibre-users.sqlite

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
    auth = {
      mode = "basic";
      enable = true;
      userDb = config.sops.secrets."calibre-users.sqlite".path;
    };
    libraries = [
      library
    ];
  };

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
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      ExecStart = "${pkgs.calibre}/bin/calibredb add ${library} --recurse --library-path=${library} --automerge=overwrite";
    };
  };
}
