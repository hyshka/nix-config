{
  nixosImages.caddy = {
    configuration = ./configuration.nix;
  };

  resource.incus_instance.caddy = {
    depends_on = [ "incus_storage_volume.caddy-persist" ];
    device = [
      {
        name = "http";
        type = "proxy";
        properties = {
          listen = "tcp:0.0.0.0:80,443";
          connect = "tcp:127.0.0.1:80,443";
        };
      }
      {
        name = "persist";
        type = "disk";
        properties = {
          pool = "default";
          source = "caddy-persist";
          path = "/persist";
        };
      }
    ];
  };

  resource.incus_storage_volume."caddy-persist" = {
    name = "caddy-persist";
    pool = "default";
    project = "lab-default";
    config."security.shifted" = "true";
    lifecycle.prevent_destroy = true;
  };
}
