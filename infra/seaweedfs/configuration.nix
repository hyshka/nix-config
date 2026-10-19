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
  networking.firewall.allowedTCPPorts = [ s3Port ];

  sops.secrets.seaweedfs-s3-json = {
    sopsFile = ./secrets/seaweedfs.yaml;
  };

  systemd.services.seaweedfs = {
    description = "SeaweedFS S3 object store (weed mini)";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "sops-install-secrets.service"
    ];
    wants = [ "network-online.target" ];
    requires = [ "sops-install-secrets.service" ];

    serviceConfig = {
      DynamicUser = true;
      StateDirectory = "seaweedfs";
      WorkingDirectory = "/var/lib/seaweedfs";
      Restart = "on-failure";
      RestartSec = 10;
      # The S3 identity file holds credentials, so hand it to the service as a
      # credential rather than a world-readable path under /run/secrets.
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

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/private/seaweedfs"
    ];
  };
}
