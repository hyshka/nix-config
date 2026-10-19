{
  nixosImages.attic = {
    configuration = ./configuration.nix;
  };

  resource.incus_instance.attic = {
    device = [
      {
        name = "persist";
        type = "disk";
        properties = {
          pool = "default";
          source = "attic-persist";
          path = "/persist";
        };
      }
    ];
  };

  resource.incus_storage_volume."attic-persist" = {
    name = "attic-persist";
    pool = "default";
    project = "lab-default";
    config."security.shifted" = "true";
    lifecycle.prevent_destroy = true;
  };
}
