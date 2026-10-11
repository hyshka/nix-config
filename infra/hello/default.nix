{
  nixosImages.hello = {
    configuration = ./configuration.nix;
    remote = "starship";
  };
}
