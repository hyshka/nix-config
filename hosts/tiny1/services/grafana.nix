{config, ...}: {
  sops.secrets = {
    grafana-adminPass = {
      owner = "grafana";
      group = "grafana";
    };
  };

  services.grafana = {
    enable = true;
    dataDir = "/mnt/storage/grafana";
    settings = {
      analytics.reporting_enabled = false;
      security.admin_password = "$__file{${config.sops.secrets.grafana-adminPass.path}}";
      server = {
        http_addr = "127.0.0.1";
        http_port = 3002;
        domain = "grafana.home.hyshka.com";
        serve_from_sub_path = true;
      };
    };
  };
}
