{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [nginx];

  sops.secrets = {
    # used in service modules
    nginx_basic_auth = {
      owner = config.services.nginx.user;
      group = config.services.nginx.group;
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "bryan@hyshka.com";
    certs = {
      "home.hyshka.com" = {
        webroot = "/var/lib/acme/.challenges";
        group = "nginx";
        extraDomainNames = ["*.home.hyshka.com"];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
  };
}
