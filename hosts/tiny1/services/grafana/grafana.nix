{config, ...}: {
  sops.secrets = {
    grafana-adminPass = {
      owner = "grafana";
      group = "grafana";
    };
  };

  # https://wiki.nixos.org/wiki/Grafana
  # https://xeiaso.net/blog/prometheus-grafana-loki-nixos-2020-11-20/
  # https://github.com/nix-community/nur-combined/blob/3652fac2e8a82268eb4dcf6099144669ae253e22/repos/alarsyo/services/monitoring.nix#L40
  services.grafana = {
    enable = true;

    settings = {
      analytics.reporting_enabled = false;
      security.admin_password = "$__file{${config.sops.secrets.grafana-adminPass.path}}";
      server = {
        http_addr = "127.0.0.1";
        http_port = 3002;
        domain = "grafana.home.hyshka.com";
        root_url = "https://grafana.home.hyshka.com";
        serve_from_sub_path = true;
      };
    };

    provision = {
      enable = true;
      datasources.settings = {
        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://${config.services.prometheus.listenAddress}:${builtins.toString config.services.prometheus.port}";
            isDefault = true;
          }
          {
            name = "Loki";
            type = "loki";
            url = "http://localhost:${builtins.toString config.services.loki.configuration.server.http_listen_port}";
          }
        ];
        deleteDatasources = [
          {
            orgId = 1;
            name = "Prometheus";
          }
          {
            orgId = 1;
            name = "Loki";
          }
        ];
      };
      # TODO
      # https://github.com/ibizaman/selfhostblocks/blob/main/modules/blocks/monitoring.nix#L241
      #alerting.contactPoints.settings = {
      #  contactPoints = [{
      #    name = "ntfy";
      #    receivers = [{
      #      uid = "sysadmin";
      #      type = "webhook";
      #      settings = {
      #        url = "http://localhost:2586/grafana";
      #        http_method = "POST";
      #        authorization_header = secret_token;
      #      };
      #    }];
      #  }];
      #};
      #alerting.policies.settings = {
      #  policies = [
      #    {
      #      receiver = "webhook";
      #      group_by = ["grafana_folder" "alertname"];
      #      group_wait = "30s";
      #      group_interval = "5m";
      #      repeat_interval = "4h";
      #    }
      #  ];
      #};

      # TODO:
      # - https://grafana.com/grafana/dashboards/1860-node-exporter-full/
      # - https://grafana.com/grafana/dashboards/20802-caddy-monitoring/
      #
      # Example: https://github.com/Misterio77/nix-config/blob/692aca80fad823de5d39333a8ff10c271c1388f2/hosts/alcyone/services/grafana/default.nix#L39
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
}
