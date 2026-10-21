{
  nixosImages."forgejo-build-runner" = {
    configuration = ./configuration.nix;
    kind = "virtual-machine";
    remote = "tiny1";
  };

  resource.incus_instance."forgejo-build-runner" = {
    config."security.secureboot" = "false";
    config."limits.cpu" = "4";
    config."limits.memory" = "8GiB";

    device = [
      {
        name = "root";
        type = "disk";
        properties = {
          pool = "default";
          path = "/";
          size = "20GiB";
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
    ];
  };

  resource.incus_storage_volume."forgejo-build-runner-persist" = {
    name = "forgejo-build-runner-persist";
    remote = "tiny1";
    pool = "default";
    project = "lab-default";
    lifecycle.prevent_destroy = true;
  };
}
