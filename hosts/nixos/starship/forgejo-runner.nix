{
  config,
  pkgs,
  ...
}:
{
  sops.secrets = {
    forgejo-tofu-runner-token = { };
    incus-ci-client-key = { };
    attic-ci-token = { };
    tofu-s3-access-key = { };
    tofu-s3-secret-key = { };
    tofu-encryption = { };
  };

  services.forgejo-runner.instances.tofu = {
    enable = true;

    # Host backend: the trusted apply/drift jobs run directly on this machine.
    hostPackages = with pkgs; [
      # upstream nix module defaults
      bash
      coreutils
      curl
      gawk
      gnused
      nodejs
      wget
      # used by the apply/drift workflows
      attic-client
      cacert
      nix
    ];

    settings = {
      # Only the host label. No `:docker` label, so the module does not add the
      # podman supplementary group.
      runner.labels = [ "nixos:host" ];

      server.connections.default = {
        url = "https://code.home.hyshka.com/";
        # Replace with the UUID minted when registering this runner.
        uuid = "8534b8e5-3b3b-4561-8b0b-039c7b1c53f3";
      };
    };

    secrets.server.connections.default.token_url = config.sops.secrets.forgejo-tofu-runner-token.path;
  };

  # Hand secrets to the service as systemd credentials so they land in
  # $CREDENTIALS_DIRECTORY instead of a world-readable /run/secrets path.
  # The incus client needs a writable config dir holding client.crt/client.key,
  # so symlink them into a RuntimeDirectory it can write servercerts/ into.
  systemd.services."forgejo-runner-tofu" = {
    after = [ "sops-install-secrets.service" ];
    wants = [ "sops-install-secrets.service" ];

    serviceConfig = {
      RuntimeDirectory = "forgejo-runner/incus";
      RuntimeDirectoryMode = "0700";
      LoadCredential = [
        "client.crt:${../../../infra/ci-client.crt}"
        "client.key:${config.sops.secrets.incus-ci-client-key.path}"
        "attic-token:${config.sops.secrets.attic-ci-token.path}"
        "aws-access-key:${config.sops.secrets.tofu-s3-access-key.path}"
        "aws-secret-key:${config.sops.secrets.tofu-s3-secret-key.path}"
        "tofu-encryption:${config.sops.secrets.tofu-encryption.path}"
      ];

      CapabilityBoundingSet = "";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      ProtectProc = "invisible";
      InaccessiblePaths = [
        "/var/lib/incus"
        "/home"
      ];
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
      ];
    };

    preStart = ''
      ln -sf "$CREDENTIALS_DIRECTORY/client.crt" "$RUNTIME_DIRECTORY/client.crt"
      ln -sf "$CREDENTIALS_DIRECTORY/client.key" "$RUNTIME_DIRECTORY/client.key"
    '';
  };

  # Image builds go through the system nix daemon, not this service, so the
  # service hardening does not bound them. Cap them to leave the desktop headroom.
  nix.settings = {
    max-jobs = 8;
    cores = 4;
  };
}
