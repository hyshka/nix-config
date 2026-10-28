{
  nixosImages.ntfy = {
    configuration = ./configuration.nix;
  };

  resource.incus_instance.ntfy = {
    depends_on = [ "incus_storage_volume.ntfy-persist" ];
    device = [
      {
        name = "http";
        type = "proxy";
        properties = {
          listen = "tcp:0.0.0.0:2586";
          connect = "tcp:127.0.0.1:2586";
        };
      }
      {
        name = "persist";
        type = "disk";
        properties = {
          pool = "default";
          source = "ntfy-persist";
          path = "/persist";
        };
      }
    ];
  };

  resource.incus_storage_volume."ntfy-persist" = {
    name = "ntfy-persist";
    pool = "default";
    project = "lab-default";
    config."security.shifted" = "true";
    lifecycle.prevent_destroy = true;
  };
}
