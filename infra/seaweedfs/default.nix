{
  nixosImages.seaweedfs = {
    configuration = ./configuration.nix;
  };

  resource.incus_instance.seaweedfs = {
    depends_on = [ "incus_storage_volume.seaweedfs-persist" ];
    device = [
      {
        name = "persist";
        type = "disk";
        properties = {
          pool = "default";
          source = "seaweedfs-persist";
          path = "/persist";
        };
      }
    ];
  };

  resource.incus_storage_volume."seaweedfs-persist" = {
    name = "seaweedfs-persist";
    pool = "default";
    project = "lab-default";
    config."security.shifted" = "true";
    lifecycle.prevent_destroy = true;
  };
}
