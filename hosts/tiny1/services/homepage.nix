{config, ...}: {
  # TODO: remove after flake upgrade
  systemd.services.homepage-dashboard.environment = {
    HOMEPAGE_ALLOWED_HOSTS = "localhost:8082,127.0.0.1:8082,dashboard.home.hyshka.com";
  };

  systemd.services.homepage-dashboard.serviceConfig = {
    # Give unit access to the Docker socket
    SupplementaryGroups = ["docker"];
  };

  sops.secrets = {
    homepage = {};
  };

  services.homepage-dashboard = {
    enable = true;
    # TODO: after flake upgrade
    #allowedHosts = "dashboard.home.hyshka.com";
    environmentFile = config.sops.secrets.homepage.path;
    settings = {
      title = "tiny1";
      showStats = true;
      layout = {
        Media = {
          style = "row";
          columns = 2;
        };
      };
    };
    docker = {
      my-docker.socket = "/var/run/docker.sock";
    };
    widgets = [
      {
        resources = {
          label = "System";
          cpu = true;
          memory = true;
          cputemp = true;
          uptime = true;
          disk = "/";
        };
      }
      {
        resources = {
          label = "Storage";
          disk = "/mnt/storage";
        };
      }
    ];
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
                icon = "namecheap.svg";
                href = "https://namecheap.com";
              }
            ];
          }
          {
            Backblaze = [
              {
                icon = "backblaze.svg";
                href = "https://backblaze.com";
              }
            ];
          }
          {
            Mullvad = [
              {
                icon = "mullvad.svg";
                href = "https://mullvad.net";
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
                icon = "nixos.svg";
                href = "https://search.nixos.org/options";
              }
            ];
          }
        ];
      }
    ];
    services = [
      {
        NAS = [
          {
            Syncthing = {
              icon = "syncthing.svg";
              href = "https://syncthing.home.hyshka.com";
              description = "Main backup service, syncs all devices to the NAS";
            };
          }
          {
            Samba = {
              abbr = "SMB";
              href = "https://tbd.hyshka.com";
              description = "Time machine shares";
            };
          }
          {
            Restic = {
              icon = "restic.svg";
              href = "https://tbd.hyshka.com";
              description = "Remote backup service";
            };
          }
        ];
      }
      {
        Networking = [
          {
            "Adguard Home" = {
              icon = "adguard-home.png";
              href = "https://adguard.home.hyshka.com";
              widget = {
                type = "adguard";
                url = "http://localhost:3020";
                username = "admin";
                password = "{{HOMEPAGE_VAR_ADGUARD_PASSWORD}}";
              };
            };
          }
        ];
      }
      {
        Monitoring = [
          {
            Grafana = {
              icon = "grafana.png";
              href = "https://grafana.home.hyshka.com";
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
          #{
          #  "Silver Bullet" = {
          #    icon = "silverbullet.svg";
          #    href = "https://silverbullet.home.hyshka.com/";
          #  };
          #}
          #{
          #  "Nextcloud" = {
          #    icon = "nextcloud.svg";
          #    href = "https://cloud.home.hyshka.com/";
          #  };
          #}
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
              widget = {
                type = "immich";
                url = "http://10.223.27.125:2283";
                key = "{{HOMEPAGE_VAR_IMMICH_APIKEY}}";
                version = 2;
              };
            };
          }
          #{
          #  "CryptPad" = {
          #    icon = "cryptpad.svg";
          #    href = "https://cryptpad.home.hyshka.com/";
          #  };
          #}
          {
            "Calibre" = {
              icon = "calibre.svg";
              href = "https://library.home.hyshka.com/";
            };
          }
          {
            "Calibre Web" = {
              icon = "calibre-web.svg";
              href = "https://books.home.hyshka.com/";
            };
          }
          {
            "Ntfy" = {
              icon = "ntfy.svg";
              href = "https://ntfy.home.hyshka.com/";
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
                url = "http://localhost:8096";
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
                url = "http://localhost:5055";
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
                url = "http://localhost:7878";
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
                url = "http://localhost:8989";
                key = "{{HOMEPAGE_VAR_SONARR_APIKEY}}";
              };
            };
          }
          {
            Readarr = {
              icon = "readarr.svg";
              href = "https://readarr.home.hyshka.com";
              server = "my-docker";
              container = "readarr";
              widget = {
                type = "readarr";
                url = "http://localhost:8787";
                key = "{{HOMEPAGE_VAR_READARR_APIKEY}}";
              };
            };
          }
          {
            EbookBuddy = {
              icon = "sh-eBookBuddy";
              href = "https://ebookbuddy.home.hyshka.com";
              server = "my-docker";
              container = "ebookbuddy";
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
                url = "http://localhost:9696";
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
                url = "http://localhost:8080";
                username = "{{HOMEPAGE_VAR_QBITTORRENT_USERNAME}}";
                password = "{{HOMEPAGE_VAR_QBITTORRENT_PASSWORD}}";
              };
            };
          }
          {
            Sabnzbd = {
              icon = "sabnzbd.svg";
              href = "https://sabnzbd.home.hyshka.com";
              server = "my-docker";
              container = "sabnzbd";
              widget = {
                type = "sabnzbd";
                url = "http://localhost:8085";
                key = "{{HOMEPAGE_VAR_SABNZBD_APIKEY}}";
              };
            };
          }
        ];
      }
    ];
  };
}
