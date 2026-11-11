{
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.restic ];

  sops.secrets = {
    restic_password = { };
    restic_environmentFile = { };
  };

  services.restic.backups.hyshka = {
    passwordFile = config.sops.secrets.restic_password.path;
    environmentFile = config.sops.secrets.restic_environmentFile.path;
    initialize = true;
    extraBackupArgs = [
      "--no-scan"
      "--retry-lock=30m"
    ];
    runCheck = true;
    backupPrepareCommand = ''
      ${pkgs.findutils}/bin/find /var/lib/pocket-id -maxdepth 2 -type f -name '*.db' \
        -exec ${pkgs.sqlite}/bin/sqlite3 {} ".backup {}.bak" \;
    '';
    backupCleanupCommand = ''
      ${pkgs.findutils}/bin/find /var/lib/pocket-id -maxdepth 2 -type f -name '*.db.bak' -delete
    '';
    paths = [
      "/etc/ssh"
      "/var/lib/caddy"
      "/var/lib/pocket-id"
      "/var/lib/private/AdGuardHome"
    ];
    repository = "s3:s3.us-west-000.backblazeb2.com/storage-hyshka";
    timerConfig = {
      OnCalendar = "03:40";
      Persistent = true;
    };
  };
}
