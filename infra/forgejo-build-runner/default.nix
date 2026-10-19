{
  nixosImages."forgejo-build-runner" = {
    configuration = ./configuration.nix;
    kind = "virtual-machine";
    remote = "starship";
  };

  resource.incus_instance."forgejo-build-runner" = {
    config."security.secureboot" = "false";

    device = [
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
    remote = "starship";
    pool = "default";
    project = "lab-default";
    lifecycle.prevent_destroy = true;
  };
}
