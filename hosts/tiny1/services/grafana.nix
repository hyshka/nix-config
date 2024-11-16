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
          isDefault = true;
        }
        {
          name = "Loki";
          type = "loki";
          url = "http://localhost:${builtins.toString config.services.loki.configuration.server.http_listen_port}";
        }
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
      {
        job_name = "loki";
        static_configs = [{targets = ["127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}"];}];
      }
      {
        job_name = "alloy";
        static_configs = [{targets = ["127.0.0.1:12345"];}];
      }
    ];

    exporters = {
      node = {
        enable = true;
        enabledCollectors = ["systemd"];
        listenAddress = "127.0.0.1";
      };
      # TODO: https://github.com/MindFlavor/prometheus_wireguard_exporter
      #wireguard = {
      #  enable = true;
      #};
      # TODO: https://github.com/msroest/sabnzbd_exporter
      #sabnzbd = {
      #  enable = true;
      #};
      # TODO: https://github.com/ngosang/restic-exporter
      #restic = {
      #  enable = true;
      #};
      # TODO: https://github.com/xperimental/nextcloud-exporter
      #nextcloud = {
      #  enable = true;
      #};
    };
  };

  # https://github.com/esselius/cfg/blob/7c9f50df327b9c2b43b863efdbef5f08860eb6de/nixos-modules/profiles/monitoring.nix#L178
  services.loki = {
    enable = true;
    configuration = {
      analytics.reporting_enabled = false;
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
    extraFlags = [
      "--disable-reporting"
    ];
  };

  systemd.services.alloy.serviceConfig.SupplementaryGroups = [
    # Permission to read Caddy logs
    config.services.caddy.group
    # Permission to read Docker logs
    "docker"
    # Permission for loki.source.journal
    "adm"
    "systemd-journal"
  ];
  environment.etc = {
    "alloy/config.alloy" = {
      # Alloy config:
      # - https://github.com/tigorlazuardi/nixos/blob/33245512007158a98011a43d4eb7bb9206569229/system/services/caddy.nix#L74
      # - https://github.com/esselius/cfg/blob/7c9f50df327b9c2b43b863efdbef5f08860eb6de/nixos-modules/profiles/monitoring.nix#L231C5-L263C5
      # - https://github.com/esselius/cfg/blob/7c9f50df327b9c2b43b863efdbef5f08860eb6de/nixos-modules/profiles/monitoring.nix#L231C5-L263C5
      # - https://grafana.github.io/alloy-configurator/
      # - https://github.com/redxtech/nixfiles/blob/362dd60177f2fd096c4ec14277e6dde3e8102b01/modules/nixos/monitoring/default.nix#L276

      # TODO
      # prometheus exporters: https://grafana.com/docs/alloy/latest/reference/components/prometheus/
      # - postgres
      # - redis
      text = ''
        prometheus.remote_write "local" {
          endpoint {
            url = "http://127.0.0.1:9090/api/v1/write"
          }
        }

        loki.write "local" {
          endpoint {
            url = "http://127.0.0.1:3030/loki/api/v1/push"
          }
        }

        loki.relabel "journal" {
          forward_to = []

          rule {
            source_labels = ["__journal__systemd_unit"]
            target_label  = "unit"
          }
          rule {
            source_labels = [ "__journal__systemd_user_unit" ]
            target_label = "user_unit"
          }
          rule {
            source_labels = ["__journal__boot_id"]
            target_label  = "boot_id"
          }
          rule {
            source_labels = ["__journal__transport"]
            target_label  = "transport"
          }
          rule {
            source_labels = ["__journal_priority_keyword"]
            target_label  = "level"
          }
          rule {
            source_labels = ["__journal__hostname"]
            target_label  = "instance"
          }
        }

        loki.source.journal "read"  {
          forward_to = [loki.process.general_json_pipeline.receiver]
          relabel_rules = loki.relabel.journal.rules
          labels = {
              job = "systemd-journal",
              component = "loki.source.journal",
          }
        }

        loki.process "general_json_pipeline" {
            forward_to = [loki.write.local.receiver]

            stage.json {
                expressions = {
                    level = "level",
                }
            }

            stage.labels {
                values = {
                    level = "",
                }
            }
        }

        discovery.docker "linux" {
          host = "unix:///var/run/docker.sock"
        }

        loki.source.docker "read"  {
          host = "unix:///var/run/docker.sock"
          targets = discovery.docker.linux.targets
          forward_to = [loki.write.local.receiver]
          relabel_rules    = discovery.relabel.docker.rules
          labels = {
              job = "docker",
              component = "loki.source.docker",
          }
        }

        discovery.relabel "docker" {
            targets = []

            rule {
                source_labels = ["__meta_docker_container_name"]
                regex         = "/(.*)"
                target_label  = "container"
            }

            rule {
                source_labels = ["__meta_docker_container_log_stream"]
                target_label  = "stream"
            }
        }

        local.file_match "caddy_access_log" {
            path_targets = [
                {
                    "__path__" = "/var/log/caddy/*.log",
                },
            ]
            sync_period = "30s"
        }

        loki.source.file "caddy_access_log" {
            targets = local.file_match.caddy_access_log.targets
            forward_to = [loki.process.caddy_access_log.receiver]
        }

        loki.process "caddy_access_log" {
            forward_to = [loki.write.local.receiver]

            stage.json {
                expressions = {
                    level = "",
                    host = "request.host",
                    method = "request.method",
                    proto = "request.proto",
                    ts = "",
                }
            }

            stage.labels {
                values = {
                    level = "",
                    host = "",
                    method = "",
                    proto = "",
                }
            }

            stage.label_drop {
              values = ["service_name"]
            }

            stage.static_labels {
              values = {
                  job = "caddy_access_log",
              }
            }

            stage.timestamp {
              source = "ts"
              format = "unix"
            }
        }

        prometheus.exporter.cadvisor "cadvisor" {
            docker_host = "unix:///var/run/docker.sock"
            docker_only = true
        }

        prometheus.scrape "cadvisor" {
            targets = prometheus.exporter.cadvisor.cadvisor.targets
            forward_to = [prometheus.remote_write.local.receiver]
        }
      '';
      user = "alloy";
      group = "alloy";
    };
  };
}
