{
  config,
  ...
}:
{
  sops.secrets.pocket-id-encryption-key = {
    owner = config.services.pocket-id.user;
    group = config.services.pocket-id.group;
  };

  services.pocket-id = {
    enable = true;
    settings = {
      APP_URL = "https://auth.home.hyshka.com";
      HOST = "127.0.0.1";
      TRUST_PROXY = true;
      ANALYTICS_DISABLED = true;
      VERSION_CHECK_DISABLED = true;
    };
    environmentFile = config.sops.secrets.pocket-id-encryption-key.path;
  };
}
