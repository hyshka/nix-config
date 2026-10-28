{
  nixosImages.samba = {
    configuration = ./configuration.nix;
  };

  resource.incus_instance.samba = {
    config."raw.idmap" = "uid 1000 1000\ngid 100 100";
    device = [
      {
        name = "hyshka";
        type = "disk";
        properties = {
          source = "/mnt/storage/hyshka";
          path = "/mnt/storage/hyshka";
        };
      }
      {
        name = "mediacenter";
        type = "disk";
        properties = {
          source = "/mnt/storage/mediacenter";
          path = "/mnt/storage/mediacenter";
        };
      }
      {
        name = "tm_share";
        type = "disk";
        properties = {
          source = "/mnt/storage/tm_share";
          path = "/mnt/storage/tm_share";
        };
      }
      {
        name = "tcp";
        type = "proxy";
        properties = {
          listen = "tcp:0.0.0.0:139,445";
          connect = "tcp:127.0.0.1:139,445";
        };
      }
      {
        name = "udp";
        type = "proxy";
        properties = {
          listen = "udp:0.0.0.0:137,138";
          connect = "udp:127.0.0.1:137,138";
        };
      }
    ];
  };
}
