{
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://ntfy.home.hyshka.com";
      behind-proxy = true;
      # bind to all interfaces to receive connections from Docker containers
      listen-http = "0.0.0.0:2586";
      log-format = "json";
      log-file = "/var/log/ntfy/ntfy.log";
      metrics-listen-http = "127.0.0.1:9091";
      auth-default-access = "deny-all";
      # TODO: make declaritive
      # sudo ntfy user add --role=admin hyshka
    };
  };

  systemd.services.ntfy-sh.serviceConfig = {
    LogsDirectory = ["ntfy"];
  };
}
