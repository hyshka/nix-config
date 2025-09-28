{
  config,
  lib,
  inputs,
  ...
}: let
  container = import ./default.nix {inherit lib inputs;};
in
  container.mkContainer {
    name = "homepage";
  }
  // {
    # Allow access to docker socket from host
    users.groups.docker = {};
    systemd.services.homepage-dashboard.serviceConfig = {
      SupplementaryGroups = ["docker"];
    };

    sops.secrets.environmentFile = {
      sopsFile = ./secrets/homepage.yaml;
    };

    services.homepage-dashboard = {
      enable = true;
      openFirewall = true;
      allowedHosts = "dashboard.home.hyshka.com";
      environmentFile = config.sops.secrets.environmentFile.path;
      settings = {
        title = "tiny1";
        layout = {
          Media = {
            style = "row";
            columns = 3;
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
                siteMonitor = "https://syncthing.home.hyshka.com";
              };
            }
            {
              Samba = {
                abbr = "SMB";
                href = "smb://bryan@tiny1/hyshka/";
                description = "Time machine shares";
              };
            }
            {
              Restic = {
                icon = "restic.svg";
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
                siteMonitor = "https://adguard.home.hyshka.com";
                widget = {
                  type = "adguard";
                  url = "https://adguard.home.hyshka.com";
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
                siteMonitor = "https://grafana.home.hyshka.com";
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
                siteMonitor = "https://hass.home.hyshka.com";
              };
            }
            {
              "Silver Bullet" = {
                icon = "silverbullet.svg";
                href = "https://silverbullet.home.hyshka.com/";
                siteMonitor = "https://silverbullet.home.hyshka.com";
              };
            }
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
                siteMonitor = "https://paperless.home.hyshka.com";
              };
            }
            {
              "Immich" = {
                icon = "immich.svg";
                href = "https://immich.home.hyshka.com";
                siteMonitor = "https://immich.home.hyshka.com";
                widget = {
                  type = "immich";
                  url = "https://immich.home.hyshka.com";
                  key = "{{HOMEPAGE_VAR_IMMICH_APIKEY}}";
                  version = 2;
                };
              };
            }
            {
              "CryptPad" = {
                icon = "cryptpad.svg";
                href = "https://cryptpad.home.hyshka.com/";
                siteMonitor = "https://cryptpad.home.hyshka.com";
              };
            }
            {
              "Calibre" = {
                icon = "calibre.svg";
                href = "https://library.home.hyshka.com/";
                siteMonitor = "https://library.home.hyshka.com";
              };
            }
            {
              "Ntfy" = {
                icon = "ntfy.svg";
                href = "https://ntfy.home.hyshka.com/";
                siteMonitor = "https://ntfy.home.hyshka.com";
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
                siteMonitor = "https://jellyfin.home.hyshka.com";
                widget = {
                  type = "jellyfin";
                  url = "https://jellyfin.home.hyshka.com";
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
                siteMonitor = "https://jellyseerr.home.hyshka.com";
                widget = {
                  type = "jellyseerr";
                  url = "https://jellyseerr.home.hyshka.com";
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
                siteMonitor = "https://radarr.home.hyshka.com";
                widget = {
                  type = "radarr";
                  url = "https://radarr.home.hyshka.com";
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
                siteMonitor = "https://sonarr.home.hyshka.com";
                widget = {
                  type = "sonarr";
                  url = "https://sonarr.home.hyshka.com";
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
                siteMonitor = "https://readarr.home.hyshka.com";
                widget = {
                  type = "readarr";
                  url = "https://readarr.home.hyshka.com";
                  key = "{{HOMEPAGE_VAR_READARR_APIKEY}}";
                };
              };
            }
            {
              Prowlarr = {
                icon = "prowlarr.svg";
                href = "https://prowlarr.home.hyshka.com";
                server = "my-docker";
                container = "prowlarr";
                siteMonitor = "https://prowlarr.home.hyshka.com";
                widget = {
                  type = "prowlarr";
                  url = "https://prowlarr.home.hyshka.com";
                  key = "{{HOMEPAGE_VAR_PROWLARR_APIKEY}}";
                };
              };
            }
            {
              Qbittorrent = {
                icon = "qbittorrent.svg";
                href = "https://qbittorrent.home.hyshka.com";
                server = "my-docker";
                container = "qbittorrent";
                siteMonitor = "https://qbittorrent.home.hyshka.com";
                widget = {
                  type = "qbittorrent";
                  url = "https://qbittorrent.home.hyshka.com";
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
                siteMonitor = "https://sabnzbd.home.hyshka.com";
                widget = {
                  type = "sabnzbd";
                  url = "https://sabnzbd.home.hyshka.com";
                  key = "{{HOMEPAGE_VAR_SABNZBD_APIKEY}}";
                };
              };
            }
            {
              EbookBuddy = {
                icon = "sh-eBookBuddy";
                href = "https://ebookbuddy.home.hyshka.com";
                server = "my-docker";
                container = "ebookbuddy";
                siteMonitor = "https://ebookbuddy.home.hyshka.com";
              };
            }
            {
              Pinchflat = {
                icon = "pinchflat.svg";
                href = "https://pinchflat.home.hyshka.com";
                server = "my-docker";
                container = "pinchflat";
                siteMonitor = "https://pinchflat.home.hyshka.com";
              };
            }
            {
              Wireguard = {
                icon = "wireguard.svg";
                server = "my-docker";
                container = "wireguard";
                # TODO: check if wireguard is up?
              };
            }
            {
              Recyclarr = {
                icon = "trash-guides.png";
                server = "my-docker";
                container = "recyclarr";
              };
            }
          ];
        }
      ];
    };
  }
