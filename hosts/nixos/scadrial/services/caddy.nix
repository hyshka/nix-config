{
  config,
  pkgs,
  ...
}:
{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [ 443 ];

  sops.secrets.caddy-envFile = {
    owner = config.services.caddy.user;
    group = config.services.caddy.group;
  };

  services.caddy = {
    enable = true;
    package = pkgs.caddy-cloudflare;
    email = "bryan@hyshka.com";
    virtualHosts = {
      "adguard.home.hyshka.com" = {
        extraConfig = ''
          tls {
            dns cloudflare {env.CLOUDFLARE_API_TOKEN}
          }

          reverse_proxy 127.0.0.1:3020
        '';
      };
      "auth.home.hyshka.com" = {
        extraConfig = ''
          tls {
            dns cloudflare {env.CLOUDFLARE_API_TOKEN}
          }

          reverse_proxy 127.0.0.1:1411
        '';
      };
    };
  };

  systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.secrets.caddy-envFile.path;
}
