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
    virtualHosts."http://*.home.hyshka.com" = {
      extraConfig = ''
        @dashboard host dashboard.home.hyshka.com
        handle @dashboard {
                 reverse_proxy http://127.0.0.1:3001
        }

        @glances host glances.home.hyshka.com
        handle @glances {
                 reverse_proxy http://127.0.0.1:61208
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
