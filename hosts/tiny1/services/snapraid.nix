{
  config,
  pkgs,
  ...
}: {
  services.snapraid = {
    enable = true;
    parityFiles = [
      "/mnt/parity1/snapraid.parity"
    ];
    contentFiles = [
      "/var/snapraid.content"
      "/mnt/disk3/.snapraid.content"
    ];
    dataDisks = {
      d3 = "/mnt/disk3/";
    };
    exclude = [
      # https://github.com/IronicBadger/infra/blob/master/group_vars/morpheus.yaml#L52
      "*.unrecoverable"
      "/tmp/"
      "/lost+found/"
      "downloads/"
      "appdata/"
      "*.!sync"
      ".AppleDouble"
      "._AppleDouble"
      ".DS_Store"
      "._.DS_Store"
      ".Thumbs.db"
      ".fseventsd"
      ".Spotlight-V100"
      ".TemporaryItems"
      ".Trashes"
      ".Trash-*"
      ".AppleDB"
      ".nfo"
    ];
    # disable touch for better compatibility as a receive-only syncthing node.
    # otherwise, the sub-second timestamps will be marked as a local change and
    # prevent syncs.
    touchBeforeSync = false;
    # sync happens daily at 0100, try not to write to files during this time
    scrub = {
      # scrub entire array about once a month
      plan = 16;
    };
    # TODO healthcheck notification for sync & scrub
  };

  systemd.services = {
    snapraid-scrub.serviceConfig = with config.services.snapraid; {
      # TODO: pkgs.snapraid-collector
      #ExecStart = "${pkgs.snapraid}/bin/snapraid scrub -p ${toString scrub.plan} -o ${toString scrub.olderThan}";
    };
    snapraid-sync.serviceConfig = {
      # TODO: pkgs.snapraid-collector
      #ExecStart = "${pkgs.snapraid}/bin/snapraid sync";
    };
    # Added by me
    snapraid-smart = {
      description = "Log SMART attributes of the SnapRAID array";
      startAt = "05:00";
      path = [pkgs.snapraid pkgs.which pkgs.gawk pkgs.smartmontools]; # The systemd unit seems to override the PATH in the wrapper
      serviceConfig =
        config.systemd.services.snapraid-scrub.serviceConfig
        // {
          ExecStart = "${pkgs.bash}/bin/sh -c '${pkgs.snapraid-collector}/bin/snapraid_metrics_collector.sh smart > /var/lib/prometheus-node-exporter-text-files/snapraid_smart.prom'";
          ReadWritePaths = config.systemd.services.snapraid-sync.serviceConfig.ReadWritePaths + " /var/lib/prometheus-node-exporter-text-files";
        };
      unitConfig.After = "snapraid-sync.service";
    };
  };
}
