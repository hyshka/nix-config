{config, ...}: let
  scrapeInterval = "15s";
in {
  sops.secrets = {
    grafana-adminPass = {
      owner = "grafana";
      group = "grafana";
    };
  };

  # https://wiki.nixos.org/wiki/Grafana
  # https://github.com/nix-community/nur-combined/blob/3652fac2e8a82268eb4dcf6099144669ae253e22/repos/alarsyo/services/monitoring.nix#L40
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

    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
          jsonData = {
            timeInterval = scrapeInterval;
          };
        }
      ];
      # TODO:
      # - https://grafana.com/grafana/dashboards/1860-node-exporter-full/
      #dashboards.settings.providers = [
      #  {
      #    name = "Node Exporter";
      #    options.path = pkgs.packages.grafanaDashboards.node-exporter;
      #    disableDeletion = true;
      #  }
      #  {
      #    name = "NGINX";
      #    options.path = pkgs.packages.grafanaDashboards.nginx;
      #    disableDeletion = true;
      #  }
      #];
    };
  };

  # https://wiki.nixos.org/wiki/Prometheus
  # https://github.com/Misterio77/nix-config/blob/692aca80fad823de5d39333a8ff10c271c1388f2/hosts/alcyone/services/prometheus.nix#L10
  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";

    globalConfig = {
      scrape_interval = scrapeInterval;
    };

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = ["127.0.0.1:${toString config.services.prometheus.exporters.node.port}"];
          }
        ];
      }
    ];

    exporters = {
      node = {
        enable = true;
        enabledCollectors = ["systemd"];
        listenAddress = "127.0.0.1";
      };
    };
  };
}
