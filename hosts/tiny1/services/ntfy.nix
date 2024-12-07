{
  services.ntfy-sh = {
    enable = true;
    # default port 2586
    settings = {
      base-url = "https://ntfy.home.hyshka.com";
      behind-proxy = true;
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
