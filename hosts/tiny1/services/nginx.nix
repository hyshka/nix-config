{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ nginx ];

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
  };

  services.nginx = {
     enable = true;
     recommendedGzipSettings = true;
     recommendedOptimisation = true;
     recommendedTlsSettings = true;
  };
}
