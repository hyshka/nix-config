{pkgs, ...}: {
  services.ntfy-sh = {
    enable = true;
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

  services.ddclient.domains = ["ntfy"];
  services.caddy.virtualHosts."ntfy.hyshka.com" = {
    extraConfig = ''
      reverse_proxy :8010
    '';
  };
}
