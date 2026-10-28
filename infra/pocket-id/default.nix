{
  nixosImages.pocket-id = {
    configuration = ./configuration.nix;
  };

  resource.incus_instance.pocket-id = {
    depends_on = [ "incus_storage_volume.pocket-id-persist" ];
    device = [
      {
        name = "persist";
        type = "disk";
        properties = {
          pool = "default";
          source = "pocket-id-persist";
          path = "/persist";
        };
      }
    ];
  };

  resource.incus_storage_volume."pocket-id-persist" = {
    name = "pocket-id-persist";
    pool = "default";
    project = "lab-default";
    config."security.shifted" = "true";
    lifecycle.prevent_destroy = true;
  };
}
