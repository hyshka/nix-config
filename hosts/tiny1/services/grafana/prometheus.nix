{config, ...}: {
  services.cadvisor = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9101;
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
        job_name = "restic";
        static_configs = [
          {
            targets = ["127.0.0.1:${toString config.services.prometheus.exporters.restic.port}"];
          }
        ];
      }
      {
        job_name = "loki";
        static_configs = [{targets = ["127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}"];}];
      }
      {
        job_name = "wireguard";
        static_configs = [
          {
            targets = ["127.0.0.1:9586"];
          }
        ];
      }
      {
        job_name = "syncthing";
        static_configs = [
          {
            targets = ["127.0.0.1:8384"];
          }
        ];
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
        job_name = "immich_api";
        static_configs = [
          {
            targets = ["127.0.0.1:8091"];
          }
        ];
      }
      {
        job_name = "immich_microservices";
        static_configs = [
          {
            targets = ["127.0.0.1:8092"];
          }
        ];
      }
      {
        job_name = "incus";
        static_configs = [
          {
            metrics_path = "/1.0/metrics";
            targets = ["127.0.0.1:8444"];
          }
        ];
      }
      {
        job_name = "cadvisor";
        static_configs = [
          {
            targets = ["127.0.0.1:${toString config.services.cadvisor.port}"];
          }
        ];
      }
    ];

    exporters = {
      node = {
        enable = true;
        listenAddress = "127.0.0.1";
        enabledCollectors = ["systemd"];
        extraFlags = ["--collector.textfile.directory=/var/lib/prometheus-node-exporter-text-files"];
      };
      smartctl = {
        enable = true;
        listenAddress = "127.0.0.1";
      };
      restic = {
        enable = true;
        listenAddress = "127.0.0.1";
        repository = config.services.restic.backups.hyshka.repository;
        passwordFile = config.sops.secrets.restic_password.path;
        environmentFile = config.sops.secrets.restic_environmentFile.path;
        group = "restic";
        refreshInterval = 60 * 60 * 24; # every 24hrs
      };
      # TODO: not in nixpkgs https://github.com/henrywhitaker3/adguard-exporter
    };
  };

  system.activationScripts.node-exporter-system-version = ''
    mkdir -pm 0775 /var/lib/prometheus-node-exporter-text-files
    (
      cd /var/lib/prometheus-node-exporter-text-files
      (
        echo -n "system_version ";
        readlink /nix/var/nix/profiles/system | cut -d- -f2
      ) > system-version.prom.next
      mv system-version.prom.next system-version.prom
    )
  '';
}
