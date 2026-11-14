{
  # The cache is retired. This volume outlives the instance by one apply so the
  # destroy guard can come off first; delete this file in the next change.
  resource.incus_storage_volume."attic-persist" = {
    name = "attic-persist";
    pool = "default";
    project = "lab-default";
    config."security.shifted" = "true";
  };
}
