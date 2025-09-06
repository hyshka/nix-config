{config, ...}: {
  sops.secrets = {
    grafana-adminPass = {
      owner = "grafana";
      group = "grafana";
    };
    grafana-ntfy-access-token = {
      owner = "grafana";
      group = "grafana";
    };
    grafana-smtp-password = {
      owner = "grafana";
      group = "grafana";
    };
  };

  # https://wiki.nixos.org/wiki/Grafana
  # https://xeiaso.net/blog/prometheus-grafana-loki-nixos-2020-11-20/
  # https://github.com/nix-community/nur-combined/blob/3652fac2e8a82268eb4dcf6099144669ae253e22/repos/alarsyo/services/monitoring.nix#L40
  # https://github.com/ibizaman/selfhostblocks/blob/main/modules/blocks/monitoring.nix
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
      };
      smtp = {
        enabled = true;
        host = "smtp.protonmail.ch:587";
        user = "noreply@hyshka.com";
        password = "$__file{${config.sops.secrets.grafana-smtp-password.path}}";
        from_address = "noreply@hyshka.com";
        from_name = "No Reply";
      };
    };

    provision = {
      enable = true;

      datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            orgId = 1;
            name = "Prometheus";
            type = "prometheus";
            url = "http://${config.services.prometheus.listenAddress}:${builtins.toString config.services.prometheus.port}";
            isDefault = true;
            version = 1;
          }
          {
            orgId = 1;
            name = "Loki";
            type = "loki";
            url = "http://localhost:${builtins.toString config.services.loki.configuration.server.http_listen_port}";
            version = 1;
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

      alerting.contactPoints.settings = {
        apiVersion = 1;
        contactPoints = [
          {
            orgId = 1;
            name = "grafana-default-email";
            receivers = [
              {
                uid = "sysadmin";
                type = "email";
                settings = {
                  addresses = "bryan@hyshka.com";
                };
              }
            ];
          }
          {
            orgId = 1;
            name = "Ntfy";
            receivers = [
              # https://grafana.com/docs/grafana/latest/alerting/configure-notifications/manage-contact-points/integrations/webhook-notifier/
              {
                uid = "admin";
                type = "webhook";
                disableResolveMessage = true;
                settings = {
                  url = "http://localhost:2586/grafana";
                  httpMethod = "POST";
                  authorization_credentials = "$__file{${config.sops.secrets.grafana-ntfy-access-token.path}}";
                };
              }
            ];
          }
        ];
        deleteContactPoints = [
          {
            orgId = 1;
            name = "grafana-default-email";
          }
          {
            orgId = 1;
            name = "Ntfy";
          }
        ];
      };

      alerting.policies.settings = {
        apiVersion = 1;
        policies = [
          {
            orgId = 1;
            receiver = "grafana-default-email";
            group_by = ["grafana_folder" "alertname"];
            group_wait = "30s";
            group_interval = "5m";
            repeat_interval = "4h";
            routes = [
              {
                receiver = "Ntfy";
                matchers = [
                  "priority = low"
                ];
              }
            ];
          }
        ];
      };

      alerting.rules.settings = {
        apiVersion = 1;
        groups = [
          {
            orgId = 1;
            name = "SysAdmin";
            folder = "My Alerts";
            interval = "10m";
            # TODO: https://github.com/ibizaman/selfhostblocks/blob/main/modules/blocks/monitoring/rules.json
            rules = [];
          }
        ];
      };

      # TODO:
      # - https://grafana.com/grafana/dashboards/1860-node-exporter-full/
      # - https://grafana.com/grafana/dashboards/20802-caddy-monitoring/
      # - https://github.com/ibizaman/selfhostblocks/blob/main/modules/blocks/monitoring.nix#L205
      # - https://github.com/esselius/cfg/blob/387dd36093655d9fee1d9087118191a2d82d9a5b/nixos-modules/profiles/monitoring.nix#L131
      # Example: https://github.com/Misterio77/nix-config/blob/692aca80fad823de5d39333a8ff10c271c1388f2/hosts/alcyone/services/grafana/default.nix#L39
      dashboards.settings = {
        apiVersion = 1;
        providers = [
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
        ];
      };
    };
  };
}
