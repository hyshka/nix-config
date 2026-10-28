{
  nixosImages.jellyfin = {
    configuration = ./configuration.nix;
    project = "lab-gpu";
  };

  resource.incus_instance.jellyfin = {
    depends_on = [ "incus_storage_volume.jellyfin-persist" ];
    config."raw.idmap" = "gid 13000 13000";
    device = [
      {
        name = "persist";
        type = "disk";
        properties = {
          pool = "default";
          source = "jellyfin-persist";
          path = "/persist";
        };
      }
      {
        name = "media";
        type = "disk";
        properties = {
          source = "/mnt/storage/mediacenter/media";
          path = "/data";
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

  resource.incus_storage_volume."jellyfin-persist" = {
    name = "jellyfin-persist";
    pool = "default";
    project = "lab-gpu";
    config."security.shifted" = "true";
    lifecycle.prevent_destroy = true;
  };
}
