{
  config,
  pkgs,
  ...
}: {
  sops.secrets = {
    caddy-envFile = {
      owner = config.services.caddy.user;
      group = config.services.caddy.group;
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];
  networking.firewall.allowedUDPPorts = [443];

  services.caddy = {
    enable = true;
    package = pkgs.custom-caddy;
    email = "bryan@hyshka.com";
    # Cloudflare DNS config for hyshka.com
    # A *.home => tiny1 tailscale IP
    # must be A record instead of CNAME because of https://github.com/tailscale/tailscale/issues/7650
    virtualHosts."https://*.home.hyshka.com" = {
      extraConfig = ''
        tls {
          dns cloudflare {env.CLOUDFLARE_API_TOKEN}
        }

        @dashboard host dashboard.home.hyshka.com
        handle @dashboard {
                 reverse_proxy http://127.0.0.1:3001
        }

        @glances host glances.home.hyshka.com
        handle @glances {
                 reverse_proxy http://127.0.0.1:61208
        }

        @hass host hass.home.hyshka.com
        handle @hass {
                 reverse_proxy http://127.0.0.1:8123
        }

        @silverbullet host silverbullet.home.hyshka.com
        handle @silverbullet {
                 reverse_proxy http://127.0.0.1:3010
        }

        @jellyseerr host jellyseerr.home.hyshka.com
        handle @jellyseerr {
                 reverse_proxy http://127.0.0.1:5055
        }

        @jellyfin host jellyfin.home.hyshka.com
        handle @jellyfin {
                 reverse_proxy http://127.0.0.1:8096
        }

        @radarr host radarr.home.hyshka.com
        handle @radarr {
                 reverse_proxy http://127.0.0.1:7878
        }

        @sonarr host sonarr.home.hyshka.com
        handle @sonarr {
                 reverse_proxy http://127.0.0.1:8989
        }

        @prowlarr host prowlarr.home.hyshka.com
        handle @prowlarr {
                 reverse_proxy http://127.0.0.1:9696
        }

        @qbittorrent host qbittorrent.home.hyshka.com
        handle @qbittorrent {
                 reverse_proxy http://127.0.0.1:8080
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
