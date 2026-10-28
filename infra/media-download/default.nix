{
  nixosImages.media-download = {
    configuration = ./configuration.nix;
  };

  resource.incus_instance.media-download = {
    depends_on = [ "incus_storage_volume.media-download-persist" ];
    config."raw.idmap" = "both 0 0\ngid 13000 13000";
    device = [
      {
        name = "persist";
        type = "disk";
        properties = {
          pool = "default";
          source = "media-download-persist";
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

  resource.incus_storage_volume."media-download-persist" = {
    name = "media-download-persist";
    pool = "default";
    project = "lab-default";
    config."security.shifted" = "true";
    lifecycle.prevent_destroy = true;
  };
}
