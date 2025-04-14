{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [restic];

  sops.secrets = {
    restic_password = {};
    restic_environmentFile = {};
  };

  services.restic.backups.hyshka = {
    passwordFile = config.sops.secrets.restic_password.path;
    environmentFile = config.sops.secrets.restic_environmentFile.path;
    initialize = true;
    paths = [
      "/mnt/storage/hyshka"
      # TODO: create better system for backing up data from LXC containers
      "/mnt/storage/paperless/export"
    ];
    exclude = [
      ".snapshots"
      ".Trash-1000"
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
