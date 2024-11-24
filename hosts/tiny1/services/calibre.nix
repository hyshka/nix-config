{config, ...}: {
  # First, run calibre-server with auth disabled
  # Then, generate a users database
  # calibre-server --userdb ./calibre-users.sqlite --manage-users
  # Finally, encrypt the binary as a secret
  # to encrypt a binary: sops -e ./calibre-users.sqlite > hosts/tiny1/services/calibre-users.sqlite

  sops.secrets.calibre-userdb = {
    owner = config.services.calibre-server.user;
    group = "mediacenter";
    format = "binary";
    sopsFile = ./calibre-users.sqlite;
  };

  services.calibre-server = {
    enable = true;
    group = "mediacenter";
    port = 8083;
    # Need to listen on local and docker interfaces for Readarr
    #host = "127.0.0.1";
    auth = {
      mode = "basic";
      enable = true;
      userDb = config.sops.secrets.calibre-userdb.path;
    };
    libraries = [
      "/mnt/storage/mediacenter/media/books"
    ];
  };

  # Open port to sync with koreader
  networking.firewall.allowedTCPPorts = [8083 8084];
  services.calibre-web = {
    enable = true;
    group = "mediacenter";
    listen = {
      ip = "0.0.0.0";
      port = 8084;
    };
    options = {
      enableBookConversion = true;
      enableBookUploading = true;
      calibreLibrary = "/mnt/storage/mediacenter/media/books";
      reverseProxyAuth.enable = true;
    };
  };
}
