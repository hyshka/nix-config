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

     virtualHosts = {
      "jellyseerr.hyshka.com" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://127.0.0.1:5055";
        };
      };
      "jellyfin.hyshka.com" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://127.0.0.1:8096";
        };
      };
    };
  };
}
