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

  services.caddy = {
    enable = true;
    email = "bryan@hyshka.com";
    virtualHosts."tiny1.tail7dfc7.ts.net" = {};
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
