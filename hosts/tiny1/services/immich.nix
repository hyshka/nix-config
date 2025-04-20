# TODO: deprecated by LXC container
{config, ...}: {
  #sops.secrets = {
  #  immich-secretsFile = {
  #    owner = "immich";
  #    group = "immich";
  #  };
  #};

  # Database backups are taken nightly at 2am
  # /mnt/storage/immich/backups
  # Ref: https://immich.app/docs/administration/backup-and-restore
  services.immich = {
    enable = false;
    # Original media stored in library, upload, and profile subdirectories
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
  #users.users.immich.extraGroups = ["video" "render"];

  # Nightly backups at 3am
  services.restic.backups.hyshka.paths = [
    "/mnt/storage/immich"
  ];
  services.restic.backups.hyshka.exclude = [
    "/mnt/storage/immich/encoded-video"
    "/mnt/storage/immich/thumbs"
  ];
}
