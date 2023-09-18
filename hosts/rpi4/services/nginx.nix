{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ nginx ];

  sops.secrets = {
    nginx_basic_auth = {
      owner = config.services.nginx.user;
      group = config.services.nginx.group;
    };
  };

  # TODO split up?
  services.nginx = {
     enable = true;
     recommendedGzipSettings = true;
     recommendedOptimisation = true;
     recommendedTlsSettings = true;

     virtualHosts = {
      "psitransfer.hyshka.com" = {
         forceSSL = true;
         enableACME = true;
         locations."/" = {
           recommendedProxySettings = true;
           proxyPass = "http://127.0.0.1:3000";
           extraConfig = ''
             proxy_buffering off;
             proxy_request_buffering off;
             client_max_body_size 3g;
           '';
        };
        extraConfig = ''
           add_header Content-Security-Policy "frame-ancestors 'none'";
           add_header X-Frame-Options "DENY";
        '';
      };
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
      "ntfy.hyshka.com" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://127.0.0.1:8010";
          proxyWebsockets = true;
        };
      };
      "dashy.hyshka.com" = {
        forceSSL = true;
        enableACME = true;
	# auth file format: user:{PLAIN}password
        basicAuthFile = config.sops.secrets.nginx_basic_auth.path;
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://127.0.0.1:8888";
        };
      };
      "glances.hyshka.com" = {
        forceSSL = true;
        enableACME = true;
        basicAuthFile = config.sops.secrets.nginx_basic_auth.path;
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://127.0.0.1:61208";
        };
      };
      "dashboard.hyshka.com" = {
        forceSSL = true;
        enableACME = true;
	# auth file format: user:{PLAIN}password
        basicAuthFile = config.sops.secrets.nginx_basic_auth.path;
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://127.0.0.1:3001";
        };
      };
    };
  };
}
