{
  lib,
  inputs,
  config,
  ...
}:
let
  container = import ./default.nix { inherit lib inputs; };
in
{
  imports = [ (container.mkContainer { name = "media-arr"; }) ];

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
    dataDir = "/var/lib/prowlarr";
  };

  # Jellyseerr - Request management for Jellyfin
  services.jellyseerr = {
    enable = true;
    openFirewall = true;
    configDir = "/var/lib/jellyseerr";
  };

  # Recyclarr - Automated TRaSH guide configuration sync
  services.recyclarr = {
    enable = true;
    group = "mediacenter";
    configuration = {
      radarr = [
        {
          api_key = config.sops.secrets.radarr_api_key.path;
          base_url = "http://localhost:7878";
          instance_name = "main";
        }
      ];
      sonarr = [
        {
          api_key = config.sops.secrets.sonarr_api_key.path;
          base_url = "http://localhost:8989";
          instance_name = "main";
        }
      ];
    };
  };

  # Set up all secrets
  sops.secrets.sonarr_api_key = {
    sopsFile = ./secrets/media-arr.yaml;
    owner = config.services.recyclarr.user;
  };
  sops.secrets.radarr_api_key = {
    sopsFile = ./secrets/media-arr.yaml;
    owner = config.services.recyclarr.user;
  };

  # Add all service users to mediacenter group for shared storage access
  users.users.sonarr.extraGroups = [ "mediacenter" ];
  users.users.radarr.extraGroups = [ "mediacenter" ];
  users.users.readarr.extraGroups = [ "mediacenter" ];
  users.users.recyclarr.extraGroups = [ "mediacenter" ];

  # Persist all service data (SQLite databases, configs)
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/lib/sonarr"
      "/var/lib/radarr"
      "/var/lib/readarr"
      "/var/lib/private/prowlarr"
      "/var/lib/private/jellyseerr"
      "/var/lib/recyclarr"
    ];
  };
}
