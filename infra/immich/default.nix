{
  nixosImages.immich = {
    configuration = ./configuration.nix;
    project = "lab-gpu";
  };

  resource.incus_instance.immich = {
    depends_on = [
      "incus_storage_volume.immich_db"
    ];
    # TODO: re-own immich volumes, no data is shared on the host
    config."raw.idmap" = "both 0 999";
    # TODO: immich doesn't need lxc-core age key but it's mounted anyways
    device = [
      {
        name = "db";
        type = "disk";
        properties = {
          pool = "default";
          source = "immich_db";
          path = "/var/lib/postgresql";
        };
      }
      {
        name = "media";
        type = "disk";
        properties = {
          source = "/mnt/storage/immich";
          path = "/mnt/storage/immich/";
        };
      }
      {
        name = "gpu";
        type = "gpu";
        properties = {
          gid = "303";
        };
      }
    ];
  };

  resource.incus_storage_volume."immich_db" = {
    name = "immich_db";
    pool = "default";
    project = "lab-gpu";
    lifecycle.prevent_destroy = true;
  };
}
