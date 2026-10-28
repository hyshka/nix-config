{
  nixosImages.silverbullet = {
    configuration = ./configuration.nix;
  };

  resource.incus_instance.silverbullet = {
    depends_on = [ "incus_storage_volume.silverbullet_data" ];
    device = [
      {
        name = "space";
        type = "disk";
        properties = {
          pool = "default";
          source = "silverbullet_data";
          path = "/var/lib/silverbullet";
        };
      }
    ];
  };

  resource.incus_storage_volume."silverbullet_data" = {
    name = "silverbullet_data";
    pool = "default";
    project = "lab-default";
    config."security.shifted" = "true";
    lifecycle.prevent_destroy = true;
  };
}
