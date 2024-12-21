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
            url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
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

  # https://wiki.nixos.org/wiki/Prometheus
  # https://github.com/Misterio77/nix-config/blob/692aca80fad823de5d39333a8ff10c271c1388f2/hosts/alcyone/services/prometheus.nix#L10
  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";

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
        job_name = "smartcl";
        static_configs = [
          {
            targets = ["127.0.0.1:${toString config.services.prometheus.exporters.smartctl.port}"];
          }
        ];
      }
      {
        job_name = "loki";
        static_configs = [{targets = ["127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}"];}];
      }
      {
        job_name = "ntfy";
        static_configs = [
          {
            targets = ["127.0.0.1:9091"];
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
      smartctl = {
        enable = true;
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
    enable = false;
    extraFlags = [
      "--disable-reporting"
    ];
  };

  systemd.services.prometheus.serviceConfig.SupplementaryGroups = [
    # Permission to read Docker socket for metrics
    "docker"
  ];
  systemd.services.alloy.serviceConfig.SupplementaryGroups = [
    # Permission to read Caddy logs
    config.services.caddy.group
    # Permission to read Docker logs
    "docker"
    # Permission for loki.source.journal
    "adm"
    "systemd-journal"
  ];
  # Fix permission issue: https://github.com/grafana/alloy/issues/990
  systemd.services.alloy.serviceConfig.User = "root";
  environment.etc = {
    "alloy/config.alloy" = {
      # Alloy config:
      # - https://github.com/tigorlazuardi/nixos/blob/33245512007158a98011a43d4eb7bb9206569229/system/services/caddy.nix#L74
      # - https://github.com/esselius/cfg/blob/7c9f50df327b9c2b43b863efdbef5f08860eb6de/nixos-modules/profiles/monitoring.nix#L231C5-L263C5
      # - https://github.com/esselius/cfg/blob/7c9f50df327b9c2b43b863efdbef5f08860eb6de/nixos-modules/profiles/monitoring.nix#L231C5-L263C5
      # - https://grafana.github.io/alloy-configurator/
      # - https://github.com/redxtech/nixfiles/blob/362dd60177f2fd096c4ec14277e6dde3e8102b01/modules/nixos/monitoring/default.nix#L276
      # - https://github.com/redxtech/nixfiles/blob/15b9e0abe6f174a5ebc9c3758597653af93f58a7/modules/nixos/monitoring/default.nix#L157
      # - https://github.com/tigorlazuardi/nixos/blob/31b8f592144ad9c3459143866bc4baab75897e4d/system/services/telemetry/alloy.nix#L66

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

        discovery.relabel "docker" {
          targets = [{ __address__ = "unix:///var/run/docker.sock" }]
          rule {
            source_labels = ["__meta_docker_container_name"]
            regex         = "/(.*)"
            target_label  = "container_name"
          }
          rule {
            source_labels = ["__meta_docker_container_id"]
            target_label  = "container_id"
          }
        }

        loki.source.docker "read"  {
          host = "unix:///var/run/docker.sock"
          targets = discovery.docker.linux.targets
          forward_to = [loki.write.local.receiver]
          relabel_rules = discovery.relabel.docker.rules
          labels = {
              job = "docker",
              component = "loki.source.docker",
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

        local.file_match "ntfy_log" {
            path_targets = [
                {
                    "__path__" = "/var/log/ntfy/ntfy.log",
                },
            ]
            sync_period = "30s"
        }

        loki.source.file "ntfy_log" {
            targets = local.file_match.ntfy_log.targets
            forward_to = [loki.write.local.receiver]
        }

        prometheus.exporter.self "alloy" {}

        prometheus.scrape "alloy" {
            targets     = prometheus.exporter.self.alloy.targets
            forward_to = [prometheus.remote_write.local.receiver]
        }

        prometheus.scrape "caddy" {
            targets = [{
                __address__ = "localhost:2019",
            }]
            job_name = "caddy"
            forward_to = [prometheus.remote_write.local.receiver]
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
