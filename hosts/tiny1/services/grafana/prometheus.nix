{config, ...}: {
  systemd.services.prometheus.serviceConfig.SupplementaryGroups = [
    # Permission to read Docker socket for metrics
    "docker"
  ];

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
      {
        job_name = "caddy";
        static_configs = [
          {
            targets = ["127.0.0.1:2019"];
          }
        ];
      }
      {
        job_name = "cadvisor";
        static_configs = [
          {
            targets = ["127.0.0.1:9101"];
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
      cadvisor = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9101;
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
}
