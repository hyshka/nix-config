{
  nixosImages.forgejo = {
    configuration = ./configuration.nix;
  };

  resource.incus_instance.forgejo = {
    device = [
      {
        name = "ssh";
        type = "proxy";
        properties = {
          listen = "tcp:0.0.0.0:2222";
          connect = "tcp:0.0.0.0:2222";
          nat = "true";
        };
      }
      {
        name = "persist";
        type = "disk";
        properties = {
          pool = "default";
          source = "forgejo-persist";
          path = "/persist";
        };
      }
    ];
  };

  resource.incus_storage_volume."forgejo-persist" = {
    name = "forgejo-persist";
    pool = "default";
    config = {
      "security.shifted" = "true";
    };
  };
}
