{
  nixosImages.homepage = {
    configuration = ./configuration.nix;
  };

  resource.incus_instance.homepage = { };
}
