{
  nixosImages.calibre = {
    configuration = ./configuration.nix;
  };

  resource.incus_instance.calibre = {
    config."raw.idmap" = "both 0 0\ngid 13000 13000";
    device = [
      {
        name = "books";
        type = "disk";
        properties = {
          source = "/mnt/storage/mediacenter/media/books";
          path = "/mnt/books";
        };
      }
    ];
  };
}
