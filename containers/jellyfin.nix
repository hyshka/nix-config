{
  config,
  lib,
  inputs,
  ...
}:
let
  container = import ./default.nix { inherit lib inputs; };
in
container.mkContainer {
  name = "jellyfin";
}
// {
  # Create mediacenter group matching host GID for storage access
  users.groups.mediacenter = {
    gid = 13000;
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "jellyfin";
    group = "mediacenter";
    # Use same paths as prior Docker environment to avoid requiring database updates
    configDir = "/config";
    dataDir = "/config/data";
    cacheDir = "/config/cache";
    logDir = "/config/log";

    # Hardware acceleration for transcoding
    # Intel QuickSync (QSV) support
    # Device will be passed through via: incus config device add jellyfin gpu gpu
  };

  # Add jellyfin user to video and render groups for GPU access
  users.users.jellyfin.extraGroups = [
    "video"
    "render"
    "mediacenter"
  ];

  # Persist Jellyfin data
  environment.persistence."/persist" = {
    directories = [
      "/config"
    ];
  };
}
