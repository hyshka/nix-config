{
  config,
  lib,
  inputs,
  ...
}: let
  container = import ./default.nix {inherit lib inputs;};
in
  container.mkContainer {
    name = "immich";
  }
  // {
    # Set up steps
    # 1. Deploy image to Incus
    # 2. Create container: incus create nixos/custom/immich immich -c security.nesting=true
    # 3. Add persist disk: incus config device add immich persist disk source=/persist/microvms/immich path=/persist shift=true
    # 4. Start container: incus start immich --console
    # 5. Configure static ip: Grab IPv4 from incus list, then incus config device override immich eth0 ipv4.address=10.223.27.125
    # 6. Compute age key: nix-shell -p ssh-to-age --run 'sudo cat /persist/microvms/immich/etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
    # 7. Update nix-config with static IP and age key, rebuild the image
    # 8. Add data storage: incus config device add immich data disk source=/mnt/storage/immich path=/mnt/immich/ raw.mount.options=idmap=b:998:0:1
    # 9. Set raw.idmap: incus config set immich raw.idmap=both 0 998

    # Manual backup on NixOS host
    # sudo -u postgres pg_dumpall --clean --if-exists --username=postgres | gzip > "../immich-dump.sql.gz"
    # Restore backup
    # incus exec --user 71 immich -- psql -U immich -W -d immich
    # sudo gunzip --stdout "/mnt/storage/immich/backups/immich-db-backup-1745049600009.sql.gz" \
    # | sed "s/SELECT pg_catalog.set_config('search_path', '', false);/SELECT pg_catalog.set_config('search_path', 'public, pg_catalog', true);/g" \
    # | incus exec --user 998 immich -- psql --dbname=immich --username=immich

    # Move database to custom volume
    # 1. incus storage volume create default immich_db
    # 2. attach to tmp path: incus storage volume attach default immich_db immich /mnt/immich_db/
    # 3. stop services
    # 4. copy data: incus exec immich -- cp -r /var/lib/postgresql/* /mnt/immich_db/
    # 5. backup: incus exec immich -- mv /var/lib/postgresql /postgresql_bak
    # 6. incus config device set immich immich_db path=/var/lib/postgresql
    # 7. start services
    # 8. incus exec immich -- rm -rf /postgresql_bak

    networking.firewall.allowedTCPPorts = [2283 8091 8092];
    sops.secrets.secretsFile = {
      sopsFile = ./secrets/immich.yaml;
    };

    # TODO: restarting incus container deletes the database
    # Database backups are taken nightly at 2am
    # /mnt/storage/immich/backups
    # Ref: https://immich.app/docs/administration/backup-and-restore
    services.immich = {
      enable = true;
      # Original media stored in library, upload, and profile subdirectories
      mediaLocation = "/mnt/storage/immich/";
      secretsFile = config.sops.secrets.secretsFile.path;
      host = "0.0.0.0";
      # https://immich.app/docs/install/environment-variables
      environment = {
        IMMICH_TRUSTED_PROXIES = "127.0.0.1,10.223.27.125";
        IMMICH_METRICS = "true";
        IMMICH_TELEMETRY_INCLUDE = "all"; # enable prometheus metrics
        IMMICH_API_METRICS_PORT = "8091";
        IMMICH_MICROSERVICES_METRICS_PORT = "8092";
      };
    };

    # Hardware Accelerated Transcoding
    users.users.immich.extraGroups = ["video" "render"];
  }
