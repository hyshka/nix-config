{
  config,
  lib,
  pkgs,
  ...
}:
let
  storePort = 9333;
  s3Port = 8333;
in
{
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ s3Port ];

  sops.secrets.seaweedfs-s3-json = { };

  systemd.services.seaweedfs = {
    description = "SeaweedFS S3 object store (weed mini)";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
    ]
    ++ lib.optional config.sops.useSystemdActivation "sops-install-secrets.service";
    wants = [ "network-online.target" ];
    requires = lib.optional config.sops.useSystemdActivation "sops-install-secrets.service";

    serviceConfig = {
      DynamicUser = true;
      StateDirectory = "seaweedfs";
      WorkingDirectory = "/var/lib/seaweedfs";
      Restart = "on-failure";
      RestartSec = 10;
      LoadCredential = [ "s3.json:${config.sops.secrets.seaweedfs-s3-json.path}" ];
      ExecStart = lib.concatStringsSep " " [
        "${pkgs.seaweedfs}/bin/weed"
        "mini"
        "-dir=/var/lib/seaweedfs"
        "-master.port=${toString storePort}"
        "-s3.port=${toString s3Port}"
        "-s3.config=%d/s3.json"
        "-bucket=nix-config-tofu"
      ];
    };
  };
}
