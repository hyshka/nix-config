{
  config,
  lib,
  inputs,
  ...
}: let
  container = import ./default.nix {inherit lib inputs;};
in
  container.mkContainer {
    name = "paperless";
  }
  // {
    # Application
    networking.firewall.allowedTCPPorts = [28981];
    sops.secrets.paperless-passwordFile = {
      sopsFile = ./secrets/paperless.yaml;
    };

    services.paperless = {
      enable = true;
      # map root on host to paperless (315) in the container
      # incus config device add paperless data disk source=/mnt/storage/paperless path=/mnt/paperless/ raw.mount.options=idmap=b:315:0:1
      # incus config set paperless raw.idmap=both 0 315
      mediaDir = "/mnt/paperless/";
      passwordFile = config.sops.secrets.paperless-passwordFile.path;
      address = "0.0.0.0";
      # https://docs.paperless-ngx.com/configuration/
      settings = {
        PAPERLESS_URL = "https://paperless.home.hyshka.com";
        PAPERLESS_TRUSTED_PROXIES = "127.0.0.1,10.223.27.210";
      };
    };
  }
