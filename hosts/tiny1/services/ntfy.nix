{ pkgs, ... }:
{
  services.ntfy-sh = {
      enable = false;
      settings = {
      	base-url = "https://ntfy.hyshka.com";
      	listen-http = "0.0.0.0:8010";
      	behind-proxy = true;
      	auth-default-access = "deny-all";
      	# requires:
      	# sudo mkdir /var/lib/ntfy-sh/
      	# sudo touch /var/lib/ntfy-sh/user.db
      	# sudo chown ntfy-sh:ntfy-sh /var/lib/ntfy-sh/user.db
      	# sudo chmod 600 /var/lib/ntfy-sh/user.db
      	# ntfy user add --role=admin hyshka
      	auth-file = "/var/lib/ntfy-sh/user.db";
      	#log-level = "DEBUG";
      };
  };

  services.nginx.virtualHosts."ntfy.hyshka.com" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:8010";
      proxyWebsockets = true;
    };
  };
}
