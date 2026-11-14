{
  config,
  ...
}:
let
  domain = "home.hyshka.com";

  mkService =
    subdomain: attrs:
    {
      href = "https://${subdomain}.${domain}";
      siteMonitor = "https://${subdomain}.${domain}";
    }
    // attrs;
in
{
  sops.secrets.environmentFile = {
    sopsFile = ./secrets/homepage.yaml;
  };

  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
    allowedHosts = "dashboard.home.hyshka.com";
    environmentFiles = [ config.sops.secrets.environmentFile.path ];

    settings = {
      title = "hyshka";
      headerStyle = "clean";
      statusStyle = "dot";
      hideVersion = true;
      useEqualHeights = true;
      layout = {
        Media = {
          style = "row";
          columns = 3;
          icon = "mdi-play-box-multiple";
        };
        Home = {
          style = "row";
          columns = 4;
          icon = "mdi-home";
        };
        Infrastructure = {
          style = "row";
          columns = 3;
          icon = "mdi-server";
        };
        NAS = {
          style = "row";
          columns = 3;
          icon = "mdi-harddisk";
        };
        Administration = {
          style = "row";
          columns = 4;
          icon = "mdi-shield-account";
        };
        Development = {
          style = "row";
          columns = 3;
          icon = "mdi-code-tags";
        };
      };
    };

    widgets = [
      {
        search = {
          provider = "brave";
          focus = true;
          target = "_self";
        };
      }
    ];

    bookmarks = [
      {
        Administration = [
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
            ProtonVPN = [
              {
                icon = "si-protonvpn";
                href = "https://protonvpn.com";
              }
            ];
          }
        ];
      }
      {
        Development = [
          {
            Source = [
              {
                icon = "github.svg";
                href = "https://github.com/hyshka/nix-config";
              }
            ];
          }
          {
            "Nix Options" = [
              {
                icon = "nixos.svg";
                href = "https://search.nixos.org/options";
              }
            ];
          }
          {
            "Nix Packages" = [
              {
                icon = "nixos.svg";
                href = "https://search.nixos.org/packages";
              }
            ];
          }
        ];
      }
    ];

    services = [
      {
        Media = [
          {
            Jellyfin = mkService "jellyfin" {
              icon = "jellyfin.svg";
              description = "Movies and TV";
              widget = {
                type = "jellyfin";
                url = "https://jellyfin.${domain}";
                key = "{{HOMEPAGE_VAR_JELLYFIN_APIKEY}}";
                enableNowPlaying = true;
              };
            };
          }
          {
            Seerr = mkService "jellyseerr" {
              icon = "seerr.svg";
              description = "Media requests";
              widget = {
                type = "seerr";
                url = "https://jellyseerr.${domain}";
                key = "{{HOMEPAGE_VAR_JELLYSEERR_APIKEY}}";
              };
            };
          }
          {
            Sonarr = mkService "sonarr" {
              icon = "sonarr.svg";
              description = "TV series";
              widget = {
                type = "sonarr";
                url = "https://sonarr.${domain}";
                key = "{{HOMEPAGE_VAR_SONARR_APIKEY}}";
              };
            };
          }
          {
            Radarr = mkService "radarr" {
              icon = "radarr.svg";
              description = "Movies";
              widget = {
                type = "radarr";
                url = "https://radarr.${domain}";
                key = "{{HOMEPAGE_VAR_RADARR_APIKEY}}";
              };
            };
          }
          {
            Bindery = mkService "bindery" {
              icon = "bindery.svg";
              description = "Books and audiobooks";
            };
          }
          {
            Prowlarr = mkService "prowlarr" {
              icon = "prowlarr.svg";
              description = "Indexers";
              widget = {
                type = "prowlarr";
                url = "https://prowlarr.${domain}";
                key = "{{HOMEPAGE_VAR_PROWLARR_APIKEY}}";
              };
            };
          }
          {
            QBittorrent = mkService "qbittorrent" {
              icon = "qbittorrent.svg";
              description = "Torrent client over VPN";
              widget = {
                type = "qbittorrent";
                url = "https://qbittorrent.${domain}";
                username = "{{HOMEPAGE_VAR_QBITTORRENT_USERNAME}}";
                password = "{{HOMEPAGE_VAR_QBITTORRENT_PASSWORD}}";
              };
            };
          }
          {
            Sabnzbd = mkService "sabnzbd" {
              icon = "sabnzbd.svg";
              description = "Usenet client over VPN";
              widget = {
                type = "sabnzbd";
                url = "https://sabnzbd.${domain}";
                key = "{{HOMEPAGE_VAR_SABNZBD_APIKEY}}";
              };
            };
          }
          {
            Pinchflat = mkService "pinchflat" {
              icon = "pinchflat.png";
              description = "YouTube archive";
            };
          }
          {
            Recyclarr = {
              icon = "trash-guides.png";
              description = "TRaSH guide sync";
            };
          }
          {
            Wireguard = {
              icon = "wireguard.svg";
              description = "ProtonVPN tunnel, media-download";
            };
          }
        ];
      }
      {
        Home = [
          {
            "Home Assistant" = mkService "hass" {
              icon = "home-assistant.svg";
              description = "Home automation";
            };
          }
          {
            Immich = mkService "immich" {
              icon = "immich.svg";
              description = "Photo library";
              widget = {
                type = "immich";
                url = "https://immich.${domain}";
                key = "{{HOMEPAGE_VAR_IMMICH_APIKEY}}";
                version = 2;
              };
            };
          }
          {
            "Immich Kiosk" = mkService "immich-kiosk" {
              icon = "immich-kiosk.svg";
              description = "Photo frame display";
            };
          }
          {
            Paperless = mkService "paperless" {
              icon = "paperless-ngx.svg";
              description = "Document archive";
            };
          }
          {
            Library = mkService "library" {
              icon = "calibre.svg";
              description = "Ebook server";
            };
          }
          {
            SilverBullet = mkService "silverbullet" {
              icon = "silverbullet.png";
              description = "Notes";
            };
          }
          {
            Ntfy = mkService "ntfy" {
              icon = "ntfy.svg";
              description = "Push notifications";
            };
          }
        ];
      }
      {
        Infrastructure = [
          {
            Forgejo = mkService "code" {
              icon = "forgejo.svg";
              description = "Git and CI";
            };
          }
          {
            SeaweedFS = {
              icon = "mdi-database";
              description = "S3 object store, tofu state";
              href = "http://tiny1.tail7dfc7.ts.net:8333";
              siteMonitor = "http://tiny1.tail7dfc7.ts.net:8333";
            };
          }
          {
            Incus = mkService "incus" {
              icon = "incus.svg";
              description = "Container and VM host";
            };
          }
          {
            "Pocket ID" = mkService "auth" {
              icon = "pocket-id.svg";
              description = "SSO provider";
            };
          }
          {
            Grafana = mkService "grafana" {
              icon = "grafana.svg";
              description = "Metrics and logs";
            };
          }
          {
            "AdGuard Home" = mkService "adguard" {
              icon = "adguard-home.png";
              description = "DNS and filtering";
              widget = {
                type = "adguard";
                url = "https://adguard.${domain}";
                username = "admin";
                password = "{{HOMEPAGE_VAR_ADGUARD_PASSWORD}}";
              };
            };
          }
        ];
      }
      {
        NAS = [
          {
            Syncthing = mkService "syncthing" {
              icon = "syncthing.svg";
              description = "File sync";
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
              icon = "restic.png";
              description = "Remote backups";
            };
          }
        ];
      }
    ];
  };
}
