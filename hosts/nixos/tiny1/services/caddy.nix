{
  config,
  pkgs,
  ...
}:
{
  sops.secrets = {
    caddy-envFile = {
      owner = config.services.caddy.user;
      group = config.services.caddy.group;
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [ 443 ];

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
      hash = "sha256-Zls+5kWd/JSQsmZC4SRQ/WS+pUcRolNaaI7UQoPzJA0=";
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
           reverse_proxy http://10.223.27.114:8082
         }

         @hass host hass.home.hyshka.com
         handle @hass {
           reverse_proxy http://10.223.27.45:8123
         }

         @silverbullet host silverbullet.home.hyshka.com
         handle @silverbullet {
          reverse_proxy http://10.223.27.35:3000
         }

         @adguard host adguard.home.hyshka.com
         handle @adguard {
           reverse_proxy http://127.0.0.1:3020
         }

         @paperless host paperless.home.hyshka.com
         handle @paperless {
           reverse_proxy http://10.223.27.210:28981
         }

         @immich host immich.home.hyshka.com
         handle @immich {
           reverse_proxy http://10.223.27.125:2283
         }

         @immich-kiosk host immich-kiosk.home.hyshka.com
         handle @immich-kiosk {
           reverse_proxy http://10.223.27.216:3000
         }

         @cryptpad host cryptpad.home.hyshka.com cryptpad-sandbox.home.hyshka.com
         handle @cryptpad {
           reverse_proxy http://10.223.27.23:3006
           handle /cryptpad_websocket/* {
             reverse_proxy http://10.223.27.23:3003
           }
         }

        # The Caddy rules for Nextcloud were too complex. Reverse proxy the
        # buit-in Nginx configuration instead.
        #@cloud host cloud.home.hyshka.com
        #handle @cloud {
        #  reverse_proxy http://127.0.0.1:8082
        #}

        @grafana host grafana.home.hyshka.com
        handle @grafana {
          reverse_proxy http://127.0.0.1:3002
        }

        @jellyseerr host jellyseerr.home.hyshka.com
        handle @jellyseerr {
          reverse_proxy http://10.223.27.55:5055
        }

        @jellyfin host jellyfin.home.hyshka.com
        handle @jellyfin {
          reverse_proxy http://10.223.27.100:8096
        }

        @radarr host radarr.home.hyshka.com
        handle @radarr {
          reverse_proxy http://10.223.27.55:7878
        }

        @readarr host readarr.home.hyshka.com
        handle @readarr {
          reverse_proxy http://10.223.27.55:8787
        }

        @sonarr host sonarr.home.hyshka.com
        handle @sonarr {
          reverse_proxy http://10.223.27.55:8989
        }

        @prowlarr host prowlarr.home.hyshka.com
        handle @prowlarr {
          reverse_proxy http://10.223.27.55:9696
        }

        @qbittorrent host qbittorrent.home.hyshka.com
        handle @qbittorrent {
          reverse_proxy http://10.223.27.8:8080
        }

        @sabnzbd host sabnzbd.home.hyshka.com
        handle @sabnzbd {
          reverse_proxy http://10.223.27.8:8085
        }

        @library host library.home.hyshka.com
        handle @library {
          reverse_proxy http://10.223.27.241:8083
        }

        @ntfy host ntfy.home.hyshka.com
        handle @ntfy {
          reverse_proxy http://10.223.27.234:2586
        }

        @pinchflat host pinchflat.home.hyshka.com
        handle @pinchflat {
          reverse_proxy http://10.223.27.121:8945
        }

        @syncthing host syncthing.home.hyshka.com
        handle @syncthing {
          reverse_proxy http://127.0.0.1:8384 {
            header_up Host {upstream_hostport}
          }
        }

        @auth host auth.home.hyshka.com
        handle @auth {
          reverse_proxy http://10.223.27.36:1411
        }

        # Fallback for otherwise unhandled domains
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

  services.tailscale = {
    permitCertUid = config.services.caddy.user;
  };
}
