{
  config,
  inputs,
  pkgs,
  ...
}: {
  # TODO immich module only available in unstable
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/web-apps/immich.nix"
  ];
  # Override package lookup from module with unstable
  nixpkgs.config = {
    packageOverrides = {
      immich = pkgs.unstable.immich;
    };
  };

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
    };
  };
}
