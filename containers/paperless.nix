{
  config,
  lib,
  inputs,
  ...
}:
let
  container = import ./default.nix { inherit lib inputs; };
in
container.mkContainer {
  name = "paperless";
}
// {
  # Before upgrade
  # incus file pull paperless/var/lib/paperless/db.sqlite3 .
  # After upgrade
  # incus file push ../db.sqlite3 paperless/var/lib/paperless/db.sqlite3
  # incus exec paperless -- paperless-manage migrate

  networking.firewall.allowedTCPPorts = [ 28981 ];
  sops.secrets.paperless-passwordFile = {
    sopsFile = ./secrets/paperless.yaml;
  };

  services.paperless = {
    enable = true;
    mediaDir = "/mnt/paperless/";
    passwordFile = config.sops.secrets.paperless-passwordFile.path;
    address = "0.0.0.0";
    # https://docs.paperless-ngx.com/configuration/
    settings = {
      PAPERLESS_URL = "https://paperless.home.hyshka.com";
      PAPERLESS_TRUSTED_PROXIES = "127.0.0.1,10.223.27.210";
    };
    # Full backup run at 01:30
    exporter = {
      enable = true;
      directory = "/mnt/paperless/export";
    };
  };

  # Override package to skip tests
  nixpkgs.overlays = [
    (_final: prev: {
      paperless-ngx = prev.paperless-ngx.overrideAttrs (oldAttrs: {
        doCheck = false;
        disabledTests = (oldAttrs.disabledTests or [ ]) ++ [
          "test_favicon_view"
          "test_favicon_view_missing_file"
        ];
      });
    })
  ];
}
