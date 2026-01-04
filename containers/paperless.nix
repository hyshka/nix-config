{
  config,
  lib,
  inputs,
  pkgs,
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
  sops.secrets.paperless-oauth2-client-secret = {
    sopsFile = ./secrets/paperless.yaml;
    owner = config.services.paperless.user;
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
              client_id = "c02787b2-416a-4055-a484-934b2ff11088";
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
      directory = "/mnt/paperless/export";
    };
  };

  # Add secret to PAPERLESS_SOCIALACCOUNT_PROVIDERS
  systemd.services.paperless-web.script = lib.mkBefore ''
    oidcSecret=$(< ${config.sops.secrets.paperless-oauth2-client-secret.path})
    export PAPERLESS_SOCIALACCOUNT_PROVIDERS=$(
      ${pkgs.jq}/bin/jq <<< "$PAPERLESS_SOCIALACCOUNT_PROVIDERS" \
        --compact-output \
        --arg oidcSecret "$oidcSecret" '.openid_connect.APPS.[0].secret = $oidcSecret'
    )
  '';

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
