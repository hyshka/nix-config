{
  config,
  pkgs,
  ...
}:
let
  # Host bridge IP for proxying services on the host
  host_ip = "10.223.27.1";
in
{
  # Persist only Caddy's ACME state; logs stay on the root disk.
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/caddy"
    ];
  };

  sops.secrets.caddy-envFile = {
    sopsFile = ./secrets/caddy.yaml;
    owner = config.services.caddy.user;
    group = config.services.caddy.group;
  };

  services.caddy = {
    enable = true;
    openFirewall = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
      hash = "sha256-Oirb6ZtU/c6C/SfICWpfBAEGDTepWShPQdWW0LlhF20=";
    };
    email = "bryan@hyshka.com";
    logFormat = ''
      level INFO
    '';
    globalConfig = ''
      servers {
        metrics
      }
    '';
    # Cloudflare DNS config for hyshka.com
    # A *.home => tiny1 tailscale IP
    # must be A record instead of CNAME because of https://github.com/tailscale/tailscale/issues/7650
    virtualHosts."https://*.home.hyshka.com" = {
      logFormat = ''
        output file ${config.services.caddy.logDir}/access-*.home.hyshka.com.log {
          # Allow caddy group to read logs, used by Promtail
          mode 640
        }
      '';
      extraConfig = ''
        tls {
          dns cloudflare {env.CLOUDFLARE_API_TOKEN}
        }

        @dashboard host dashboard.home.hyshka.com
        handle @dashboard {
          reverse_proxy http://homepage.incus:8082
        }

        @hass host hass.home.hyshka.com
        handle @hass {
          reverse_proxy http://haos.incus:8123
        }

        @silverbullet host silverbullet.home.hyshka.com
        handle @silverbullet {
          reverse_proxy http://silverbullet.incus:3000
        }

        @adguard host adguard.home.hyshka.com
        handle @adguard {
          reverse_proxy http://${host_ip}:3020
        }

        @paperless host paperless.home.hyshka.com
        handle @paperless {
          reverse_proxy http://paperless.incus:28981
        }

        @immich host immich.home.hyshka.com
        handle @immich {
          reverse_proxy http://immich.incus:2283
        }

        @immich-kiosk host immich-kiosk.home.hyshka.com
        handle @immich-kiosk {
          reverse_proxy http://immich-kiosk.incus:3000
        }

        @grafana host grafana.home.hyshka.com
        handle @grafana {
          reverse_proxy http://${host_ip}:3002
        }

        @jellyseerr host jellyseerr.home.hyshka.com
        handle @jellyseerr {
          reverse_proxy http://media-arr.incus:5055
        }

        @jellyfin host jellyfin.home.hyshka.com
        handle @jellyfin {
          reverse_proxy http://jellyfin.incus:8096
        }

        @radarr host radarr.home.hyshka.com
        handle @radarr {
          reverse_proxy http://media-arr.incus:7878
        }

        @bindery host bindery.home.hyshka.com
        handle @bindery {
          reverse_proxy http://media-arr.incus:8787
        }

        @sonarr host sonarr.home.hyshka.com
        handle @sonarr {
          reverse_proxy http://media-arr.incus:8989
        }

        @prowlarr host prowlarr.home.hyshka.com
        handle @prowlarr {
          reverse_proxy http://media-arr.incus:9696
        }

        @qbittorrent host qbittorrent.home.hyshka.com
        handle @qbittorrent {
          reverse_proxy http://media-download.incus:8080
        }

        @sabnzbd host sabnzbd.home.hyshka.com
        handle @sabnzbd {
          reverse_proxy http://media-download.incus:8085
        }

        @library host library.home.hyshka.com
        handle @library {
          reverse_proxy http://calibre.incus:8083
        }

        @ntfy host ntfy.home.hyshka.com
        handle @ntfy {
          reverse_proxy http://ntfy.incus:2586
        }

        @pinchflat host pinchflat.home.hyshka.com
        handle @pinchflat {
          reverse_proxy http://pinchflat.incus:8945
        }

        @syncthing host syncthing.home.hyshka.com
        handle @syncthing {
          reverse_proxy http://${host_ip}:8384 {
            header_up Host {upstream_hostport}
          }
        }

        @auth host auth.home.hyshka.com
        handle @auth {
          reverse_proxy http://pocket-id.incus:1411
        }

        @code host code.home.hyshka.com
        handle @code {
          reverse_proxy forgejo.incus:3000
        }

        @incus host incus.home.hyshka.com
        handle @incus {
          reverse_proxy https://${host_ip}:8443 {
            # can't configure Incus public address, must pass correct forwarded headers for oidc callback to work
            header_up Host incus.home.hyshka.com
            transport http {
              tls_insecure_skip_verify
            }
          }
        }

        @cache host cache.home.hyshka.com
        handle @cache {
          reverse_proxy http://attic.incus:8080
        }

        @s3 host s3.home.hyshka.com
        handle @s3 {
          reverse_proxy http://seaweedfs.incus:8333
        }

        handle {
          abort
        }
      '';
    };
  };

  systemd.services.caddy = {
    serviceConfig = {
      EnvironmentFile = config.sops.secrets.caddy-envFile.path;
    };
  };
}
