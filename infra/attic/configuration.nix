{
  config,
  ...
}:
{
  networking.firewall.allowedTCPPorts = [ 8080 ];

  sops.secrets.attic-env = {
    sopsFile = ./secrets/attic.yaml;
  };

  services.atticd = {
    enable = true;
    environmentFile = config.sops.secrets.attic-env.path;
    settings = {
      listen = "[::]:8080";
      allowed-hosts = [ "cache.home.hyshka.com" ];
      api-endpoint = "https://cache.home.hyshka.com/";
    };
  };

  systemd.services.atticd = {
    after = [ "sops-install-secrets.service" ];
    wants = [ "sops-install-secrets.service" ];
  };

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/private/atticd"
    ];
  };
}
