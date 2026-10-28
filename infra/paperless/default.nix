{
  nixosImages.paperless = {
    configuration = ./configuration.nix;
  };

  resource.incus_instance.paperless = {
    depends_on = [ "incus_storage_volume.paperless_data" ];
    device = [
      {
        name = "data";
        type = "disk";
        properties = {
          pool = "default";
          source = "paperless_data";
          path = "/var/lib/paperless";
        };
      }
      {
        name = "media";
        type = "disk";
        properties = {
          pool = "default";
          source = "paperless-media";
          path = "/mnt/paperless-media";
        };
      }
      {
        name = "export";
        type = "disk";
        properties = {
          pool = "default";
          source = "paperless-export";
          path = "/mnt/paperless-export";
        };
      }
    ];
  };

  resource.incus_storage_volume."paperless_data" = {
    name = "paperless_data";
    pool = "default";
    project = "lab-default";
    config."security.shifted" = "true";
    lifecycle.prevent_destroy = true;
  };

  resource.incus_storage_volume."paperless-media" = {
    name = "paperless-media";
    pool = "default";
    project = "lab-default";
    config."security.shifted" = "true";
    lifecycle.prevent_destroy = true;
  };

  resource.incus_storage_volume."paperless-export" = {
    name = "paperless-export";
    pool = "default";
    project = "lab-default";
    config."security.shifted" = "true";
    lifecycle.prevent_destroy = true;
  };
}
