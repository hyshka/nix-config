{
  config,
  pkgs,
  lib,
  ...
}:
let
  collector = "${pkgs.snapraid-collector}/bin/snapraid_metrics_collector.sh";
  textfileDir = "/var/lib/prometheus-node-exporter-text-files";
  logDir = "/var/log/snapraid-collector";
  scrub = config.services.snapraid.scrub;
in
{
  services.snapraid = {
    enable = true;
    parityFiles = [
      "/mnt/parity2/snapraid.parity"
    ];
    contentFiles = [
      "/var/snapraid.content"
      "/mnt/disk1/.snapraid.content"
      "/mnt/disk3/.snapraid.content"
    ];
    dataDisks = {
      d1 = "/mnt/disk1/";
      d3 = "/mnt/disk3/";
    };
    exclude = [
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
      # scrub entire array about once every three months
      plan = 8;
    };
  };

  # Override Snapraid services to use snapraid-collector
  systemd.services = {
    snapraid-scrub.serviceConfig = {
      ExecStart = lib.mkForce "${collector} --textfile ${textfileDir}/snapraid_scrub.prom --log-dir ${logDir} --scrub-defaults '-p ${toString scrub.plan} -o ${toString scrub.olderThan}' scrub";
      LogsDirectory = "snapraid-collector";
      WorkingDirectory = logDir;
    };
    snapraid-sync.serviceConfig = {
      ExecStart = lib.mkForce "${collector} --textfile ${textfileDir}/snapraid_sync.prom --log-dir ${logDir} sync";
      LogsDirectory = "snapraid-collector";
      WorkingDirectory = logDir;
    };
    snapraid-smart = {
      description = "Log SMART attributes of the SnapRAID array";
      startAt = "05:00";
      serviceConfig =
        # Copy hardened unit config
        config.systemd.services.snapraid-scrub.serviceConfig // {
          ExecStart = "${collector} --textfile ${textfileDir}/snapraid_smart.prom --log-dir ${logDir} smart";
          LogsDirectory = "snapraid-collector";
          WorkingDirectory = logDir;
          ReadWritePaths = textfileDir;
          # Allow unit to access SMART attributes of all "sd" block devices
          PrivateDevices = false;
          DeviceAllow = "block-sd rw";
          CapabilityBoundingSet = "CAP_SYS_RAWIO";
        };
      unitConfig.After = "snapraid-sync.service";
    };
  };
}
