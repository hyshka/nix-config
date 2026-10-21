{
  config,
  lib,
  ...
}:
let
  cacheProxyPort = 42000;
  cacheDir = "/var/lib/forgejo-cache";
  atticKeyFile = ../attic/cache-public-key.txt;
  atticKey = lib.optionalString (builtins.pathExists atticKeyFile) (
    lib.removeSuffix "\n" (builtins.readFile atticKeyFile)
  );
in
{
  # A full VM, so podman can run job containers without LXC nesting. It carries
  # only the untrusted docker label; the trusted apply/drift jobs run on Starship.

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

  # Renovate's job container runs as the containerbase `ubuntu` user (uid
  # 12021), which needs to write its cache volume.
  systemd.tmpfiles.rules = [
    "d ${cacheDir}/renovate 0770 root root -"
    "d ${cacheDir}/nix 0755 root root -"
  ];

  virtualisation.podman.enable = true;

  # dbus-broker can reload into an empty policy on this VM, denying podman's
  # StartTransientUnit calls and failing every job container. Manage cgroups
  # directly so podman never talks to systemd over the system bus.
  virtualisation.containers.containersConf.settings.engine.cgroup_manager = "cgroupfs";

  sops.defaultSopsFile = ./secrets/forgejo-build-runner.yaml;
  sops.secrets.forgejo-build-runner-token = { };

  services.forgejo-runner.instances.build = {
    enable = true;

    settings = {
      runner = {
        capacity = 2;
        labels = [
          # Closest thing to a GitHub-hosted ubuntu runner (~550 MiB compressed)
          "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-24.04"
        ];
        envs = lib.optionalAttrs (atticKey != "") {
          NIX_CONFIG = ''
            extra-substituters = https://cache.home.hyshka.com/nix-config
            extra-trusted-public-keys = ${atticKey}
          '';
        };
      };

      server.connections.default = {
        url = "https://code.home.hyshka.com/";
        uuid = "f265f0e9-a15d-498b-ae84-9a54ad70e180";
      };

      container = {
        # Cap job containers. Keep the safe defaults for privileged/network.
        options = "--memory=4g --cpus=2 --volume ${cacheDir}/nix:/nix";
        # Persist caches across job containers on the root disk.
        valid_volumes = [
          "${cacheDir}/renovate"
          "${cacheDir}/nix"
        ];
      };

      cache = {
        enabled = true;
        host = "host.containers.internal";
        proxy_port = cacheProxyPort;
      };
    };

    secrets.server.connections.default.token_url = config.sops.secrets.forgejo-build-runner-token.path;
  };

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/forgejo-runner"
    ];
  };
}
