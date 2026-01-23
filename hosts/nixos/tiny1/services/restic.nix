{
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [ restic ];

  sops.secrets = {
    restic_password = { };
    restic_environmentFile = { };
  };

  services.restic.backups.hyshka = {
    passwordFile = config.sops.secrets.restic_password.path;
    environmentFile = config.sops.secrets.restic_environmentFile.path;
    initialize = true;
    extraBackupArgs = [
      "--no-scan" # disable backup progress estimation to reduce I/O
    ];
    # TODO: alert if there are check issues
    # TODO: determine best options for --read-data-subset
    runCheck = true;
    paths = [
      "/mnt/storage/hyshka"
      "/mnt/storage/tm_share" # time machine samba share
      "/home/hyshka/media" # *arr configs TODO: remove after migration
      # TODO: create better system for backing up data from LXC containers
      "/mnt/storage/paperless/export"
      "/mnt/storage/immich"
      "/mnt/storage/silverbullet"
      # Persisted container data
      "/persist/microvms"
    ];
    exclude = [
      ".snapshots"
      ".Trash-1000"
      # TODO: create better system for backing up data from LXC containers
      "/mnt/storage/immich/encoded-video"
      "/mnt/storage/immich/thumbs"
      "/persist/microvms/jellyfin/config/cache"
    ];
    repository = "s3:s3.us-west-000.backblazeb2.com/storage-hyshka";
    timerConfig = {
      OnCalendar = "03:00";
      Persistent = true;
    };
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
      "--keep-yearly 2"
    ];
  };
}
