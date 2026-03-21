{ config, ... }:
{
  systemd.services.promtail.serviceConfig.SupplementaryGroups = [
    # TODO: Permission to read Caddy logs
    # Permission for systemd journal
    "adm"
    "systemd-journal"
  ];

  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 3031;
        grpc_listen_port = 0;
      };

      positions = {
        filename = "/var/lib/promtail/positions.yaml";
      };

      clients = [
        {
          url = "http://localhost:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push";
        }
      ];

      scrape_configs = [
        {
          job_name = "systemd-journal";
          journal = {
            json = true;
            max_age = "12h";
            labels = {
              job = "systemd-journal";
              host = "${config.networking.hostName}";
            };
          };
          relabel_configs = [
            {
              source_labels = [ "__journal__systemd_unit" ];
              target_label = "unit";
            }
            {
              source_labels = [ "__journal__systemd_user_unit" ];
              target_label = "user_unit";
            }
            {
              source_labels = [ "__journal__boot_id" ];
              target_label = "boot_id";
            }
            {
              source_labels = [ "__journal_priority_keyword" ];
              target_label = "level";
            }
          ];
        }
        # TODO: fix logs now that they come from incus containers
        #{
        #  job_name = "caddy";
        #  static_configs = [
        #    {
        #      targets = [ "localhost" ];
        #      labels = {
        #        job = "caddy";
        #        host = "${config.networking.hostName}";
        #        __path__ = "/persist/microvms/caddy/var/log/caddy/*.log";
        #      };
        #    }
        #  ];
        #}
        #{
        #  job_name = "ntfy";
        #  static_configs = [
        #    {
        #      targets = [ "localhost" ];
        #      labels = {
        #        job = "ntfy";
        #        host = "${config.networking.hostName}";
        #        __path__ = "/var/log/ntfy/ntfy.log";
        #      };
        #    }
        #  ];
        #}
      ];
    };
  };
}
