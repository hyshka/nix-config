{config, ...}: {
  sops.secrets.microbin-passwordFile = {};

  services.microbin = {
    enable = true;
    passwordFile = config.sops.secrets.microbin-passwordFile.path;
    dataDir = "/mnt/storage/microbin/";
    settings = {
      MICROBIN_PORT = 8081;
      MICROBIN_BIND = "127.0.0.1";
      MICROBIN_PUBLIC_PATH = "https://microbin.hyshka.com/";
      MICROBIN_MAX_FILE_SIZE_UNENCRYPTED_MB = 1024;
    };
  };

  services.ddclient.domains = ["microbin"];
  services.caddy.virtualHosts."microbin.hyshka.com" = {
    extraConfig = ''
      reverse_proxy :8081
    '';
  };
}
