{
  nixosImages.pinchflat = {
    configuration = ./configuration.nix;
  };

  resource.incus_instance.pinchflat = {
    depends_on = [ "incus_storage_volume.pinchflat-persist" ];
    config."raw.idmap" = "both 0 0\ngid 13000 13000";
    device = [
      {
        name = "persist";
        type = "disk";
        properties = {
          pool = "default";
          source = "pinchflat-persist";
          path = "/persist";
        };
      }
      {
        name = "downloads";
        type = "disk";
        properties = {
          source = "/mnt/storage/mediacenter/media/youtube";
          path = "/downloads";
        };
      }
    ];
  };

  resource.incus_storage_volume."pinchflat-persist" = {
    name = "pinchflat-persist";
    pool = "default";
    project = "lab-default";
    config."security.shifted" = "true";
    lifecycle.prevent_destroy = true;
  };
}
