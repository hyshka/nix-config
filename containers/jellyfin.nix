{
  lib,
  inputs,
  pkgs,
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
  };

  # Required drivers for VAAPI transcoding on kaby lake
  # Device will be passed through via: incus config device add jellyfin gpu gpu
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime-legacy1
    ];
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
