{
  config,
  lib,
  pkgs,
  ...
}:
let
  cacheProxyPort = 42000;
  atticKeyFile = ../attic/cache-public-key.txt;
  atticKey = lib.optionalString (builtins.pathExists atticKeyFile) (
    lib.removeSuffix "\n" (builtins.readFile atticKeyFile)
  );
in
{
  # A full VM, so podman can run job containers without LXC nesting.

  # podman 5.8.7 regressed the archive API: copying actions through the
  # in-container /var/run -> /run symlink fails with "path escapes from
  # parent", failing every job. Pin the last known-good release until podman
  # vendors the buildah copier fix. Reintroduces CVE-2026-79705.
  # https://github.com/podman-container-tools/podman/issues/29805
  nixpkgs.overlays = [
    (_final: prev: {
      podman = prev.podman.overrideAttrs (_old: {
        version = "5.8.4";
        src = prev.fetchFromGitHub {
          owner = "podman-container-tools";
          repo = "podman";
          tag = "v5.8.4";
          hash = "sha256-zhEtMZVKiv1L72EMlwgz8sHpmvhejGp98oW63aPj+rQ=";
        };
        doInstallCheck = false;
      });
    })
  ];

  # Let job containers reach the runner's cache proxy at host.containers.internal.
  networking.firewall.interfaces."podman+".allowedTCPPorts = [ cacheProxyPort ];

  virtualisation.podman.enable = true;

  sops.defaultSopsFile = ./secrets/ci.yaml;
  sops.secrets = {
    forgejo-build-runner-token = {
      sopsFile = ./secrets/forgejo-build-runner.yaml;
    };
    incus-ci-client-key = { };
    attic-ci-token = { };
    tofu-s3-access-key = { };
    tofu-s3-secret-key = { };
    tofu-encryption = { };
  };

  services.forgejo-runner.instances.build = {
    enable = true;
    hostPackages = with pkgs; [
      # upstream nix module defaults
      bash
      coreutils
      curl
      gawk
      gnused
      nodejs
      wget
      # needed for nixos:host label
      cacert
      nix
    ];

    settings = {
      runner.labels = [
        # Closest thing to a GitHub-hosted ubuntu runner (~550 MiB compressed)
        "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-24.04"
        # Runs directly on this VM, for the trusted apply/drift jobs.
        "nixos:host"
      ];

      server.connections.default = {
        url = "https://code.home.hyshka.com/";
        uuid = "f265f0e9-a15d-498b-ae84-9a54ad70e180";
      };

      # Cap job containers. Keep the safe defaults for privileged/network.
      container.options = "--memory=2g --cpus=2";

      # Persist the Renovate containerbase tool cache across job containers.
      container.valid_volumes = [ "/var/lib/renovate-cache" ];

      cache = {
        enabled = true;
        host = "host.containers.internal";
        proxy_port = cacheProxyPort;
      };
    };

    secrets.server.connections.default.token_url = config.sops.secrets.forgejo-build-runner-token.path;
  };

  # Hand secrets to the service as systemd credentials so they land in
  # $CREDENTIALS_DIRECTORY instead of a world-readable /run/secrets path.
  systemd.services."forgejo-runner-build".serviceConfig.LoadCredential = [
    "client.crt:${../ci-client.crt}"
    "client.key:${config.sops.secrets.incus-ci-client-key.path}"
    "attic-token:${config.sops.secrets.attic-ci-token.path}"
    "aws-access-key:${config.sops.secrets.tofu-s3-access-key.path}"
    "aws-secret-key:${config.sops.secrets.tofu-s3-secret-key.path}"
    "tofu-encryption:${config.sops.secrets.tofu-encryption.path}"
  ];
  systemd.services."forgejo-runner-build" = {
    after = [ "sops-install-secrets.service" ];
    wants = [ "sops-install-secrets.service" ];
  };

  # The runner builds every image and runs OpenTofu. Keep the build from
  # monopolising the VM.
  nix.settings = lib.mkMerge [
    {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      max-jobs = 4;
      cores = 0;
    }
    (lib.mkIf (atticKey != "") {
      extra-substituters = [ "https://cache.home.hyshka.com/nix-config" ];
      extra-trusted-public-keys = [ atticKey ];
    })
  ];

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/forgejo-runner"
      "/var/lib/containers" # podman image cache
      "/var/lib/renovate-cache" # renovate containerbase cache
    ];
  };
}
