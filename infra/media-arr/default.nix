{
  nixosImages.media-arr = {
    configuration = ./configuration.nix;
  };

  resource.incus_instance.media-arr = {
    depends_on = [ "incus_storage_volume.media-arr-persist" ];
    # TODO: drop service uids and rely on mediacenter group instead, requires re-own
    config."raw.idmap" =
      "both 0 0\nuid 274 274\nuid 275 275\nuid 997 997\nuid 998 998\nuid 61654 61654\ngid 13000 13000";
    device = [
      {
        name = "persist";
        type = "disk";
        properties = {
          pool = "default";
          source = "media-arr-persist";
          path = "/persist";
        };
      }
      {
        name = "data";
        type = "disk";
        properties = {
          source = "/mnt/storage/mediacenter";
          path = "/data";
        };
      }
    ];
  };

  resource.incus_storage_volume."media-arr-persist" = {
    name = "media-arr-persist";
    pool = "default";
    project = "lab-default";
    config."security.shifted" = "true";
    lifecycle.prevent_destroy = true;
  };
}
