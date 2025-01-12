{config, ...}: {
  sops.secrets = {
    immich-secretsFile = {
      owner = "immich";
      group = "immich";
    };
  };

  # TODO: database backups
  # https://immich.app/docs/administration/backup-and-restore
  services.immich = {
    enable = true;
    mediaLocation = "/mnt/storage/immich/";
    secretsFile = config.sops.secrets.immich-secretsFile.path;
    port = 3005;
    host = "127.0.0.1";
    # https://immich.app/docs/install/environment-variables
    environment = {
      IMMICH_TRUSTED_PROXIES = "127.0.0.1";
      IMMICH_METRICS = "true";
      IMMICH_TELEMETRY_INCLUDE = "all"; # enable prometheus metrics
      IMMICH_API_METRICS_PORT = "8091";
      IMMICH_MICROSERVICES_METRICS_PORT = "8092";
    };
  };

  # Hardware Accelerated Transcoding
  users.users.immich.extraGroups = ["video" "render"];
}
