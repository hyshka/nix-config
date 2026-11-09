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
    runCheck = true;
    paths = [
      "/mnt/storage/hyshka"
      "/mnt/storage/tm_share" # time machine samba share
      "/var/lib/nixos"
      "/var/lib/private/seaweedfs"
      "/mnt/storage/paperless/export"
      "/mnt/storage/immich"
      "/mnt/storage/silverbullet"
      # Persisted container data
      "/persist/microvms"
      "/var/lib/incus/storage-pools/default/custom/"
    ];
    exclude = [
      ".snapshots"
      ".Trash-1000"
      "/mnt/storage/immich/encoded-video"
      "/mnt/storage/immich/thumbs"
      "/persist/microvms/jellyfin/config/cache"
      "/persist/microvms/jellyfin/config/transcodes"
      "/var/lib/incus/storage-pools/default/custom/lab-gpu_jellyfin-persist/config/cache"
      "/var/lib/incus/storage-pools/default/custom/lab-gpu_jellyfin-persist/config/transcodes"
      # Only backup paperless-export
      "/var/lib/incus/storage-pools/default/custom/lab-default_paperless-media"
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
