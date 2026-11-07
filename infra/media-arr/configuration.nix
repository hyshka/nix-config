{
  config,
  lib,
  pkgs,
  ...
}:
let
  decluttarrConfig = pkgs.writeText "decluttarr-config.yaml" (builtins.readFile ./decluttarr.yaml);
in
{
  system.stateVersion = lib.mkForce "26.05";

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

  # Prowlarr - Indexer proxy/aggregator
  services.prowlarr = {
    enable = true;
    openFirewall = true;
    dataDir = "/var/lib/prowlarr";
  };

  # Seerr - Request management for Jellyfin
  services.seerr = {
    enable = true;
    openFirewall = true;
  };

  # Recyclarr - Automated TRaSH guide configuration sync
  # Note: using LoadCredential requires security.nesting: true
  # https://github.com/NixOS/nixpkgs/issues/260670#issuecomment-2296628949
  services.recyclarr = {
    enable = true;
    group = "mediacenter";
    configuration = {
      radarr = {
        radarr-main = {
          api_key = {
            _secret = config.sops.secrets.radarr_api_key.path;
          };
          base_url = "http://localhost:7878";
          delete_old_custom_formats = true;
          quality_definition = {
            type = "movie";
            qualities = [
              {
                name = "WEBDL-1080p";
                min = 12.5;
                preferred = 85;
                max = 213;
              }
              {
                name = "WEBRip-1080p";
                min = 12.5;
                preferred = 85;
                max = 213;
              }
              {
                name = "Bluray-1080p";
                min = 50.8;
                preferred = 85;
                max = 213;
              }
              {
                name = "HDTV-1080p";
                min = 33.8;
                preferred = 85;
                max = 213;
              }
              {
                name = "WEBDL-720p";
                min = 12.5;
                preferred = 20;
                max = 40;
              }
              {
                name = "WEBRip-720p";
                min = 12.5;
                preferred = 20;
                max = 40;
              }
              {
                name = "Bluray-720p";
                min = 25.7;
                preferred = 30;
                max = 50;
              }
              {
                name = "HDTV-720p";
                min = 17.1;
                preferred = 20;
                max = 40;
              }
            ];
          };
          quality_profiles = [
            {
              trash_id = "d1d67249d3890e49bc12e275d989a7e9"; # HD Bluray + WEB
              name = "HD Bluray + WEB";
              reset_unmatched_scores.enabled = true;
              upgrade = {
                allowed = true;
                until_quality = "WEB 1080p";
              };
              qualities = [
                {
                  name = "WEB 1080p";
                  qualities = [
                    "WEBRip-1080p"
                    "WEBDL-1080p"
                  ];
                }
                { name = "Bluray-1080p"; }
                {
                  name = "WEB 720p";
                  qualities = [
                    "WEBRip-720p"
                    "WEBDL-720p"
                  ];
                }
                { name = "Bluray-720p"; }
              ];
            }
          ];
          custom_format_groups = {
            add = [
              {
                trash_id = "f8bf8eab4617f12dfdbd16303d8da245"; # [Optional] Golden Rule HD
                exclude = [ "dc98083864ea246d05a42df0d05f81cc" ]; # x265 (HD)
              }
            ];
          };
          custom_formats = [
            {
              trash_ids = [ "839bea857ed2c0a8e084f3cbdbd65ecb" ]; # x265 (no HDR/DV)
              score = 0;
              assign_scores_to = [ { name = "HD Bluray + WEB"; } ];
            }
          ];
        };
      };
      sonarr = {
        sonarr-main = {
          api_key = {
            _secret = config.sops.secrets.sonarr_api_key.path;
          };
          base_url = "http://localhost:8989";
          delete_old_custom_formats = true;
          quality_definition = {
            type = "series";
            qualities = [
              {
                name = "WEBDL-1080p";
                min = 10;
                preferred = 23;
                max = 57;
              }
              {
                name = "WEBRip-1080p";
                min = 10;
                preferred = 23;
                max = 57;
              }
              {
                name = "Bluray-1080p";
                min = 50.4;
                preferred = 55;
                max = 57;
              }
              {
                name = "HDTV-1080p";
                min = 10;
                preferred = 23;
                max = 57;
              }
              {
                name = "WEBDL-720p";
                min = 10;
                preferred = 15;
                max = 35;
              }
              {
                name = "WEBRip-720p";
                min = 10;
                preferred = 15;
                max = 35;
              }
              {
                name = "Bluray-720p";
                min = 17.1;
                preferred = 25;
                max = 45;
              }
              {
                name = "HDTV-720p";
                min = 10;
                preferred = 15;
                max = 35;
              }
            ];
          };
          quality_profiles = [
            {
              trash_id = "9d142234e45d6143785ac55f5a9e8dc9"; # WEB-1080p (Alternative)
              name = "WEB-1080p";
              reset_unmatched_scores.enabled = true;
              upgrade = {
                allowed = true;
                until_quality = "WEB 1080p";
              };
            }
            {
              name = "SD Fallback";
              reset_unmatched_scores.enabled = true;
              upgrade = {
                allowed = true;
                until_quality = "WEB 1080p";
              };
              qualities = [
                {
                  name = "WEB 1080p";
                  qualities = [
                    "WEBRip-1080p"
                    "WEBDL-1080p"
                  ];
                }
                { name = "Bluray-1080p"; }
                { name = "HDTV-1080p"; }
                {
                  name = "WEB 720p";
                  qualities = [
                    "WEBRip-720p"
                    "WEBDL-720p"
                  ];
                }
                { name = "Bluray-720p"; }
                { name = "HDTV-720p"; }
                { name = "Bluray-576p"; }
                {
                  name = "WEB 480p";
                  qualities = [
                    "WEBRip-480p"
                    "WEBDL-480p"
                  ];
                }
                { name = "Bluray-480p"; }
                { name = "DVD"; }
                { name = "SDTV"; }
              ];
            }
          ];
          custom_format_groups = {
            add = [
              {
                trash_id = "158188097a58d7687dee647e04af0da3"; # [Optional] Golden Rule HD
                exclude = [ "47435ece6b99a0b477caf360e79ba0bb" ]; # x265 (HD)
              }
            ];
          };
          custom_formats = [
            {
              trash_ids = [ "9b64dff695c2115facf1b6ea59c9bd07" ]; # x265 (no HDR/DV)
              score = 0;
              assign_scores_to = [ { name = "WEB-1080p"; } ];
            }
          ];
        };
      };
    };
  };

  # Decluttarr - Queue cleaner for *arr apps
  # Ensure config exists before OCI containers start
  systemd.services.decluttarr-config = {
    description = "Prepare decluttarr config";
    after = [ "local-fs.target" ];
    before = [ "podman-decluttarr.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p /var/lib/decluttarr
      chmod 644 /var/lib/decluttarr/config.yaml 2>/dev/null || true
      cat ${decluttarrConfig} > /var/lib/decluttarr/config.yaml
      chmod 644 /var/lib/decluttarr/config.yaml
      ls -la /var/lib/decluttarr/
    '';
  };

  virtualisation.oci-containers.containers.decluttarr = {
    image = "ghcr.io/manimatter/decluttarr:latest";
    volumes = [
      "/var/lib/decluttarr:/app/config"
      "/data/media:/data/media:ro"
    ];
    environment = {
      TZ = "America/Edmonton";
    };
    environmentFiles = [ config.sops.secrets.decluttarr_env.path ];
    extraOptions = [
      "--network=host"
    ];
  };
  systemd.services."podman-decluttarr".serviceConfig = {
    RestartSec = "1s";
    RestartSteps = 6;
    RestartMaxDelaySec = "60s";
  };

  networking.firewall.allowedTCPPorts = [ 8787 ];
  systemd.tmpfiles.rules = [
    "d /var/lib/bindery 0755 bindery mediacenter - -"
  ];
  virtualisation.oci-containers.containers.bindery = {
    image = "ghcr.io/vavallee/bindery:latest";
    user = "999:13000";
    volumes = [
      "/var/lib/bindery:/config"
      "/data:/data"
    ];
    environment = {
      TZ = "America/Edmonton";
      BINDERY_DOWNLOAD_DIR = "/data/downloads";
      BINDERY_LIBRARY_DIR = "/data/media/books";
      BINDERY_AUDIOBOOK_DIR = "/data/media/audiobooks";
      # Because prowlarr is on the same host
      BINDERY_DOWNLOAD_ALLOW_LOOPBACK = "1";
    };
    extraOptions = [
      "--network=host"
      "--umask=0002"
    ];
  };
  systemd.services."podman-bindery".serviceConfig = {
    RestartSec = "1s";
    RestartSteps = 6;
    RestartMaxDelaySec = "60s";
  };

  # Set up all secrets
  sops.secrets.sonarr_api_key = {
    sopsFile = ./secrets/media-arr.yaml;
  };
  sops.secrets.radarr_api_key = {
    sopsFile = ./secrets/media-arr.yaml;
  };
  sops.secrets.decluttarr_env = {
    sopsFile = ./secrets/media-arr.yaml;
  };

  # Add all service users to mediacenter group for shared storage access
  users.users.sonarr.extraGroups = [ "mediacenter" ];
  users.users.radarr.extraGroups = [ "mediacenter" ];
  users.users.recyclarr.extraGroups = [ "mediacenter" ];
  users.users.bindery = {
    isSystemUser = true;
    uid = 999;
    group = "mediacenter";
  };
  systemd.services.sonarr.serviceConfig.UMask = lib.mkForce "0002";
  systemd.services.radarr.serviceConfig.UMask = lib.mkForce "0002";

  # Persist all service data (SQLite databases, configs)
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/lib/sonarr"
      "/var/lib/radarr"
      "/var/lib/private/prowlarr"
      "/var/lib/private/seerr"
      "/var/lib/recyclarr"
      "/var/lib/decluttarr"
      "/var/lib/bindery"
    ];
  };
}
