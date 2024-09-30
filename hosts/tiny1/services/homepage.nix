{config, ...}: let
  # Ref: https://github.com/nikitawootten/infra/blob/main/hosts/hades/lab/homepage.nix
  settings = {
    title = "tiny1";
    showStats = true;
  };
  settingsFile = builtins.toFile "homepage-settings.yaml" (builtins.toJSON settings);
  bookmarks = [
    {
      Administration = [
        {
          Source = [
            {
              icon = "github.svg";
              href = "https://github.com/hyshka/nix-config";
            }
          ];
        }
        {
          Cloudflare = [
            {
              icon = "cloudflare.svg";
              href = "https://dash.cloudflare.com/";
            }
          ];
        }
        {
          Namecheap = [
            {
              abbr = "NC";
              href = "https://namecheap.com";
            }
          ];
        }
      ];
    }
    {
      Development = [
        {
          "Nix Options Search" = [
            {
              abbr = "NS";
              href = "https://search.nixos.org/options";
            }
          ];
        }
      ];
    }
  ];
  bookmarksFile = builtins.toFile "homepage-bookmarks.yaml" (builtins.toJSON bookmarks);

  widgets = [
    {
      resources = {
        cpu = true;
        memory = true;
        cputemp = true;
        uptime = true;
        disk = "/";
      };
    }
    {
      search = {
        provider = "duckduckgo";
        target = "_blank";
      };
    }
  ];
  widgetsFile = builtins.toFile "homepage-widgets.yaml" (builtins.toJSON widgets);

  docker = {
    my-docker.socket = "/var/run/docker.sock";
  };
  dockerFile = builtins.toFile "homepage-docker.yaml" (builtins.toJSON docker);

  # TODO https://github.com/nikitawootten/infra/blob/main/hosts/hades/lab/homepage.nix#L77
  services = [
    {
      Backup = [
        {
          Syncthing = {
            icon = "syncthing.svg";
            href = "https://tbd.hyshka.com";
            description = "Main backup service, syncs all devices to the NAS";
          };
        }
        {
          Restic = {
            icon = "backblaze.svg";
            href = "https://tbd.hyshka.com";
            description = "Remote backup service";
          };
        }
        {
          Backblaze = {
            icon = "backblaze.svg";
            href = "https://backblaze.com";
            description = "Remote storage";
          };
        }
      ];
    }
    {
      Infrastructure = [
        {
          Glances = {
            icon = "glances.png";
            href = "https://glances.home.hyshka.com";
          };
        }
        {
          Grafana = {
            icon = "grafana.png";
            href = "https://grafana.home.hyshka.com";
          };
        }
        {
          Mullvad = {
            icon = "mullvad.svg";
            href = "https://mullvad.net";
          };
        }
        {
          "Adguard Home" = {
            icon = "adguard-home.png";
            href = "https://adguard.home.hyshka.com";
          };
        }
      ];
    }
    {
      Home = [
        {
          "Home Assistant" = {
            icon = "home-assistant.svg";
            href = "https://hass.home.hyshka.com/";
          };
        }
        {
          "Silver Bullet" = {
            icon = "silverbullet.svg";
            href = "https://silverbullet.home.hyshka.com/";
          };
        }
        {
          "Nextcloud" = {
            icon = "nextcloud.svg";
            href = "https://cloud.home.hyshka.com/";
          };
        }
        {
          "Paperless" = {
            icon = "paperless.svg";
            href = "https://paperless.home.hyshka.com/";
          };
        }
        {
          "Immich" = {
            icon = "immich.svg";
            href = "https://immich.home.hyshka.com/";
          };
        }
      ];
    }
    {
      Media = [
        {
          Jellyfin = {
            icon = "jellyfin.svg";
            href = "https://jellyfin.home.hyshka.com";
            description = "Jellyfin: Media server";
            server = "my-docker";
            container = "jellyfin";
            widget = {
              type = "jellyfin";
              url = "http://jellyfin:8096";
              key = "{{HOMEPAGE_VAR_JELLYFIN_APIKEY}}";
              enableNowPlaying = true;
            };
          };
        }
        {
          Jellyseerr = {
            icon = "jellyseerr.svg";
            href = "https://jellyseerr.home.hyshka.com";
            server = "my-docker";
            container = "jellyseerr";
            widget = {
              type = "jellyseerr";
              url = "http://jellyseerr:5055";
              key = "{{HOMEPAGE_VAR_JELLYSEERR_APIKEY}}";
            };
          };
        }
        {
          Radarr = {
            icon = "radarr.svg";
            href = "https://radarr.home.hyshka.com";
            server = "my-docker";
            container = "radarr";
            widget = {
              type = "radarr";
              url = "http://radarr:7878";
              key = "{{HOMEPAGE_VAR_RADARR_APIKEY}}";
            };
          };
        }
        {
          Sonarr = {
            icon = "sonarr.svg";
            href = "https://sonarr.home.hyshka.com";
            server = "my-docker";
            container = "sonarr";
            widget = {
              type = "sonarr";
              url = "http://sonarr:8989";
              key = "{{HOMEPAGE_VAR_SONARR_APIKEY}}";
            };
          };
        }
        {
          Prowlarr = {
            icon = "prowlarr.svg";
            href = "https://prowlarr.home.hyshka.com";
            server = "my-docker";
            container = "prowlarr";
            widget = {
              type = "prowlarr";
              url = "http://prowlarr:9696";
              key = "{{HOMEPAGE_VAR_PROWLARR_APIKEY}}";
            };
          };
        }
        {
          Recyclarr = {
            icon = "trash-guides.png";
            href = "https://tbd.hyshka.com";
            server = "my-docker";
            container = "recyclarr";
          };
        }
        {
          Qbittorrent = {
            icon = "qbittorrent.svg";
            href = "https://qbittorrent.home.hyshka.com";
            server = "my-docker";
            container = "qbittorrent";
            widget = {
              type = "qbittorrent";
              url = "http://wireguard:8080";
              username = "{{HOMEPAGE_VAR_QBITTORRENT_USERNAME}}";
              password = "{{HOMEPAGE_VAR_QBITTORRENT_PASSWORD}}";
            };
          };
        }
        {
          Wireguard = {
            icon = "wireguard.svg";
            href = "https://tbd.hyshka.com";
            server = "my-docker";
            container = "wireguard";
          };
        }
      ];
    }
  ];
  servicesFile = builtins.toFile "homepage-services.yaml" (builtins.toJSON services);
in {
  virtualisation = {
    oci-containers = {
      containers.homepage = {
        image = "ghcr.io/gethomepage/homepage:latest";
        autoStart = true;
        ports = ["127.0.0.1:3001:3000"];
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock:ro"
          # TODO logs
          #"${config.lib.lab.mkConfigDir "homepage"}/logs/:/config/logs/"
          "${settingsFile}:/config/settings.yaml"
          "${servicesFile}:/config/services.yaml"
          "${bookmarksFile}:/config/bookmarks.yaml"
          "${widgetsFile}:/config/widgets.yaml"
          "${dockerFile}:/config/docker.yaml"
        ];
        environmentFiles = [config.sops.secrets.homepage.path];
        extraOptions = ["--network=media_default"];
      };
    };
  };

  sops.secrets = {
    homepage = {};
  };
}
