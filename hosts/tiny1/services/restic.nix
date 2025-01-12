{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [restic];

  sops.secrets = {
    restic_password = {
      owner = config.users.users.hyshka.name;
      group = "restic";
    };
    restic_environmentFile = {
      owner = config.users.users.hyshka.name;
      group = "restic";
    };
  };

  services.restic.backups.hyshka = {
    user = "hyshka";
    passwordFile = config.sops.secrets.restic_password.path;
    environmentFile = config.sops.secrets.restic_environmentFile.path;
    initialize = true;
    paths = [
      "/mnt/storage/hyshka"
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
  };
}
