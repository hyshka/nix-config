{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.upsnap;
  isCustomDataDir = cfg.dataDir != "/var/lib/upsnap";

  inherit (lib)
    types
    mkOption
    mkEnableOption
    getExe
    mkIf
    mkPackageOption
    optional
    ;
in
{
  options = {
    services.upsnap = {
      enable = mkEnableOption "UpSnap, A simple wake on lan web app written with SvelteKit, Go and PocketBase";
      package = mkPackageOption pkgs "upsnap" { };
      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/upsnap";
        description = ''
          The directory where UpSnap stores its data files.

          Note: A bind mount will be used to mount the directory at the expected location
          if a different value than `/var/lib/upsnap` is used.
        '';
      };
      host = mkOption {
        type = types.str;
        default = "localhost";
        description = "The host that immich will listen on.";
      };
      port = mkOption {
        type = types.port;
        default = 8090;
        description = "The port that immich will listen on.";
      };
      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to open the immich port in the firewall";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd = {
      services.upsnap = {
        description = "UpSnap";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          DynamicUser = true;
          StateDirectory = "upsnap";
          ExecStart = "${getExe cfg.package} serve --http ${builtins.toString cfg.host}:${builtins.toString cfg.port} --dir /var/lib/upsnap";
          Restart = "on-failure";
          AmbientCapabilities = "CAP_NET_RAW";
          CapabilityBoundingSet = "CAP_NET_RAW";
        };
      };

      tmpfiles.settings."10-upsnap".${cfg.dataDir}.d = mkIf isCustomDataDir {
        user = "root";
        group = "root";
        mode = "0700";
      };

      mounts = optional isCustomDataDir {
        what = cfg.dataDir;
        where = "/var/lib/private/upsnap";
        options = "bind";
        wantedBy = [ "local-fs.target" ];
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };
  };
}
