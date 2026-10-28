{
  config,
  lib,
  pkgs,
  ...
}:
{
  # No /persist volume; the base image's fake mount would fail without one.
  fileSystems."/persist".enable = lib.mkForce false;
  environment.persistence."/persist".directories = lib.mkForce [ ];

  # Before upgrade
  # incus file pull paperless/var/lib/paperless/db.sqlite3 .
  # After upgrade
  # incus file push ../db.sqlite3 paperless/var/lib/paperless/db.sqlite3
  # incus exec paperless -- paperless-manage migrate

  networking.firewall.allowedTCPPorts = [ 28981 ];
  sops.secrets.paperless-passwordFile = {
    sopsFile = ./secrets/paperless.yaml;
  };
  sops.secrets.paperless-oauth2-client-secret = {
    sopsFile = ./secrets/paperless.yaml;
    owner = config.services.paperless.user;
  };

  services.paperless = {
    enable = true;
    mediaDir = "/mnt/paperless-media";
    passwordFile = config.sops.secrets.paperless-passwordFile.path;
    address = "0.0.0.0";
    # https://docs.paperless-ngx.com/configuration/
    settings = {
      PAPERLESS_URL = "https://paperless.home.hyshka.com";
      PAPERLESS_TRUSTED_PROXIES = "10.223.27.0/24";
      # Pocket ID auth
      PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
      PAPERLESS_SOCIALACCOUNT_PROVIDERS = builtins.toJSON {
        openid_connect = {
          SCOPE = [
            "openid"
            "profile"
            "email"
          ];
          OAUTH_PKCE_ENABLED = true;
          APPS = [
            {
              provider_id = "pocket-id";
              name = "Pocket-ID";
              client_id = "063c8dcb-f4e6-461b-a54a-74ede6a3e4a0";
              # secret will be added dynamically
              #secret = "";
              settings.server_url = "https://auth.home.hyshka.com/";
            }
          ];
        };
      };
    };
    # Full backup run at 01:30
    exporter = {
      enable = true;
      directory = "/mnt/paperless-export";
    };
  };

  # Add secret to PAPERLESS_SOCIALACCOUNT_PROVIDERS at runtime
  systemd.services.paperless-web.serviceConfig.ExecStart = lib.mkForce (
    pkgs.writeShellScript "paperless-web" ''
      set -eu
      oidcSecret=$(< ${config.sops.secrets.paperless-oauth2-client-secret.path})
      export PAPERLESS_SOCIALACCOUNT_PROVIDERS=$(
        ${pkgs.jq}/bin/jq <<< "$PAPERLESS_SOCIALACCOUNT_PROVIDERS" \
          --compact-output \
          --arg oidcSecret "$oidcSecret" '.openid_connect.APPS.[0].secret = $oidcSecret'
      )
      exec ${lib.getExe config.services.paperless.package.python.pkgs.granian} --interface asginl --ws paperless.asgi:application
    ''
  );

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
