{
  inputs,
  config,
  pkgs,
  ...
}: let
  scrapeInterval = "15s";
in {
  # TODO alloy module only available in unstable
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/monitoring/alloy.nix"
  ];
  # Override package lookup from module with unstable
  nixpkgs.config = {
    packageOverrides = {
      grafana-alloy = pkgs.unstable.grafana-alloy;
    };
  };

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
        {
          name = "Loki";
          type = "loki";
          url = "http://localhost:${builtins.toString config.services.loki.configuration.server.http_listen_port}";
        }
        #{ job_name = "alloy"; static_configs = [{ targets = [ "127.0.0.1:12345" ]; }]; }
      ];
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
      {
        job_name = "caddy";
        static_configs = [
          {
            targets = ["127.0.0.1:2019"];
          }
        ];
      }
    ];

    # TODO
    # - https://github.com/msroest/sabnzbd_exporter
    exporters = {
      node = {
        enable = true;
        enabledCollectors = ["systemd"];
        listenAddress = "127.0.0.1";
      };
    };
  };

  # https://github.com/esselius/cfg/blob/7c9f50df327b9c2b43b863efdbef5f08860eb6de/nixos-modules/profiles/monitoring.nix#L178
  services.loki = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 3030;
        log_level = "warn";
      };
      auth_enabled = false;

      ingester = {
        lifecycler = {
          address = "127.0.0.1";
          ring = {
            kvstore.store = "inmemory";
            replication_factor = 1;
          };
          final_sleep = "0s";
        };
        chunk_idle_period = "5m";
        chunk_retain_period = "30s";
      };

      schema_config.configs = [
        {
          from = "2024-04-01";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }
      ];

      storage_config = {
        tsdb_shipper = {
          active_index_directory = "/var/lib/loki/tsdb-index";
          cache_location = "/var/lib/loki/tsdb-cache";
          cache_ttl = "24h";
        };
        filesystem.directory = "/var/lib/loki/chunks";
      };

      compactor = {
        working_directory = "/var/lib/loki";
        compactor_ring = {
          kvstore = {
            store = "inmemory";
          };
        };
      };
    };
  };

  # https://github.com/esselius/cfg/blob/7c9f50df327b9c2b43b863efdbef5f08860eb6de/nixos-modules/profiles/monitoring.nix#L231C5-L263C5
  # https://grafana.com/docs/alloy/latest/
  services.alloy = {
    enable = true;
  };

  environment.etc = {
    "alloy/config.alloy" = {
      text = ''
        loki.relabel "journal" {
          forward_to = []

          rule {
            source_labels = ["__journal__systemd_unit"]
            target_label  = "unit"
          }
        }

        loki.source.journal "read"  {
          forward_to    = [loki.write.endpoint.receiver]
          relabel_rules = loki.relabel.journal.rules
          labels        = {component = "loki.source.journal"}
        }

        loki.write "endpoint" {
          endpoint {
            url = "http://127.0.0.1:3030/loki/api/v1/push"
          }
        }
      '';
      user = "alloy";
      group = "alloy";
    };
  };
}
