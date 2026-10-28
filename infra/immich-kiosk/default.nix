{
  nixosImages.immich-kiosk = {
    configuration = ./configuration.nix;
  };

  resource.incus_instance.immich-kiosk = { };
}
