{
  config,
  lib,
  pkgs,
  ...
}:
let
  domain = "code.home.hyshka.com";
  oidcProvider = "PocketID";
  forgejoExe = lib.getExe config.services.forgejo.package;
in
{
  networking.firewall.allowedTCPPorts = [
    3000
    2222
  ];

  sops.secrets = {
    forgejo-oidc-client-secret = {
      sopsFile = ./secrets/forgejo.yaml;
      owner = config.services.forgejo.user;
      group = config.services.forgejo.group;
    };
    forgejo-mailer-password = {
      sopsFile = ./secrets/forgejo.yaml;
      owner = config.services.forgejo.user;
      group = config.services.forgejo.group;
    };
  };

  services.forgejo = {
    enable = true;
    dump.enable = true;
    secrets.mailer.PASSWD = config.sops.secrets.forgejo-mailer-password.path;

    settings = {
      DEFAULT.APP_NAME = "code";

      server = {
        DOMAIN = domain;
        ROOT_URL = "https://${domain}/";
        LANDING_PAGE = "login";

        # Built-in SSH server for git clone/push over SSH.
        START_SSH_SERVER = true;
        SSH_DOMAIN = domain;
        SSH_PORT = 2222;
        SSH_LISTEN_PORT = 2222;
      };

      service = {
        DISABLE_REGISTRATION = true;
        ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
        SHOW_REGISTRATION_BUTTON = false;
        REQUIRE_SIGNIN_VIEW = true;
        ENABLE_NOTIFY_MAIL = true;
      };

      admin.DEFAULT_EMAIL_NOTIFICATIONS = "enabled";

      session.COOKIE_SECURE = true;

      security = {
        LOGIN_REMEMBER_DAYS = 365;
        # Caddy is a sibling container on the bridge; trust its forwarded IPs.
        REVERSE_PROXY_TRUSTED_PROXIES = "127.0.0.0/8,::1/128,10.223.27.0/24";
      };

      # Pocket ID OIDC. First user to sign in becomes the admin.
      oauth2_client = {
        ENABLE_AUTO_REGISTRATION = true;
        ACCOUNT_LINKING = "login";
        USERNAME = "nickname";
        UPDATE_AVATAR = true;
        OPENID_CONNECT_SCOPES = "email profile groups";
      };

      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "github";
      };

      repository = {
        DEFAULT_REPO_UNITS = "repo.code,repo.issues,repo.pulls,repo.actions,repo.releases,repo.wiki";
        DEFAULT_PRIVATE = "private";
        ENABLE_PUSH_CREATE_USER = true;
      };

      # Small instance: a size-limited LRU cache instead of the 50k-item default.
      # https://forgejo.org/docs/latest/admin/config-cheat-sheet/#cache-cache
      cache = {
        ADAPTER = "twoqueue";
        HOST = ''{"size":100, "recent_ratio":0.25, "ghost_ratio":0.5}'';
      };

      database.SQLITE_JOURNAL_MODE = "WAL";
      ui.DEFAULT_THEME = "forgejo-auto";

      mailer = {
        ENABLED = true;
        PROTOCOL = "smtp+starttls";
        SMTP_ADDR = "smtp.protonmail.ch";
        SMTP_PORT = 587;
        USER = "noreply@hyshka.com";
        FROM = ''"No Reply" <noreply@hyshka.com>'';
        SEND_AS_PLAIN_TEXT = true;
      };
    };
  };

  # Auth sources live in the DB, not app.ini, so reconcile the Pocket ID source
  # on every start: add it the first time, update it thereafter.
  systemd.services.forgejo = {
    after = [ "sops-install-secrets.service" ];
    wants = [ "sops-install-secrets.service" ];
    preStart = lib.mkAfter ''
      provider_id=$(${forgejoExe} admin auth list | ${pkgs.gnugrep}/bin/grep -w '${oidcProvider}' | cut -f1)
      secret="$(< ${config.sops.secrets.forgejo-oidc-client-secret.path})"
      args=(
        --name '${oidcProvider}'
        --provider openidConnect
        --key '067d20e0-f15a-41a9-9b5f-2610f0a86e6e'
        --auto-discover-url 'https://auth.home.hyshka.com/.well-known/openid-configuration'
        --scopes openid
        --scopes email
        --scopes profile
        --skip-local-2fa
      )
      if [[ -z "$provider_id" ]]; then
        ${forgejoExe} admin auth add-oauth "''${args[@]}" --secret "$secret"
      else
        ${forgejoExe} admin auth update-oauth --id "$provider_id" "''${args[@]}" --secret "$secret"
      fi
    '';
  };

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/forgejo"
    ];
  };
}
