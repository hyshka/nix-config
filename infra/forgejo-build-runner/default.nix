{
  nixosImages."forgejo-build-runner" = {
    configuration = ./configuration.nix;
    kind = "virtual-machine";
    remote = "starship";
  };

  resource.incus_instance."forgejo-build-runner" = {
    config."security.secureboot" = "false";
    config."limits.cpu" = "8";
    config."limits.memory" = "16GiB";

    device = [
      {
        name = "root";
        type = "disk";
        properties = {
          pool = "default";
          path = "/";
          size = "48GiB";
        };
      }
      {
        name = "persist";
        type = "disk";
        properties = {
          pool = "default";
          source = "forgejo-build-runner-persist";
          path = "/persist";
        };
      }
      {
        name = "cache";
        type = "disk";
        properties = {
          pool = "default";
          source = "forgejo-build-runner-cache";
        };
      }
    ];
  };

  resource.incus_storage_volume."forgejo-build-runner-persist" = {
    name = "forgejo-build-runner-persist";
    remote = "starship";
    pool = "default";
    project = "lab-default";
    lifecycle.prevent_destroy = true;
  };

  resource.incus_storage_volume."forgejo-build-runner-cache" = {
    name = "forgejo-build-runner-cache";
    remote = "starship";
    pool = "default";
    project = "lab-default";
    content_type = "block";
    config = {
      size = "20GiB";
    };
  };
}
