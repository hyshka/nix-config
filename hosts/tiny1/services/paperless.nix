{config, ...}: {
  sops.secrets.paperless-passwordFile = {};

  # default port 28981
  services.paperless = {
    enable = false;
    mediaDir = "/mnt/storage/paperless/";
    passwordFile = config.sops.secrets.paperless-passwordFile.path;
    # https://docs.paperless-ngx.com/configuration/
    settings = {
      PAPERLESS_URL = "https://paperless.home.hyshka.com";
      PAPERLESS_TRUSTED_PROXIES = "127.0.0.1";
    };
  };
}
