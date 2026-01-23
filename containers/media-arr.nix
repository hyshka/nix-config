{
  lib,
  inputs,
  ...
}:
let
  container = import ./default.nix { inherit lib inputs; };
in
container.mkContainer {
  name = "media-arr";
}
// {
  # Create mediacenter group matching host GID for storage access
  users.groups.mediacenter = {
    gid = 13000;
  };

  # Sonarr - TV series management
  services.sonarr = {
    enable = true;
    openFirewall = true;
    user = "sonarr";
    group = "mediacenter";
    dataDir = "/var/lib/sonarr";
  };

  # Radarr - Movie management
  services.radarr = {
    enable = true;
    openFirewall = true;
    user = "radarr";
    group = "mediacenter";
    dataDir = "/var/lib/radarr";
  };

  # Readarr - Book management
  services.readarr = {
    enable = true;
    openFirewall = true;
    user = "readarr";
    group = "mediacenter";
    dataDir = "/var/lib/readarr";
  };

  # Prowlarr - Indexer proxy/aggregator
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  # Jellyseerr - Request management for Jellyfin
  services.jellyseerr = {
    enable = true;
    openFirewall = true;
    port = 5055;
  };

  # Recyclarr - Automated TRaSH guide configuration sync
  services.recyclarr = {
    enable = true;
    # Run daily to sync quality profiles and custom formats
    configuration = {
      # Configuration will be added via secrets or direct config after initial setup
    };
  };

  # Add all service users to mediacenter group for shared storage access
  users.users.sonarr.extraGroups = [ "mediacenter" ];
  users.users.radarr.extraGroups = [ "mediacenter" ];
  users.users.readarr.extraGroups = [ "mediacenter" ];
  users.users.recyclarr.extraGroups = [ "mediacenter" ];

  # Persist all service data (SQLite databases, configs)
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/sonarr"
      "/var/lib/radarr"
      "/var/lib/readarr"
      "/var/lib/prowlarr"
      "/var/lib/jellyseerr"
      "/var/lib/private/recyclarr" # Recyclarr uses private directory
    ];
  };
}
