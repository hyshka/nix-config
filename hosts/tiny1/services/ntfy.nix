{
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://ntfy.home.hyshka.com";
      listen-http = "0.0.0.0:8010";
      cache-file = "/var/cache/ntfy/cache.db";
      attachment-cache-dir = "/var/cache/ntfy/attachments";
      behind-proxy = true;
      enable-metrics = true;
      log-format = "json";
      log-file = "/var/log/ntfy.log";
      metrics-listen-http = "127.0.0.1:9091";
      auth-default-access = "deny-all";
      # requires:
      # sudo mkdir /var/lib/ntfy-sh/
      # sudo touch /var/lib/ntfy-sh/user.db
      # sudo chown ntfy-sh:ntfy-sh /var/lib/ntfy-sh/user.db
      # sudo chmod 600 /var/lib/ntfy-sh/user.db
      # ntfy user add --role=admin hyshka
      # TODO: make declaritive
      auth-file = "/var/lib/ntfy-sh/user.db";
      #log-level = "DEBUG";
    };
  };
}
