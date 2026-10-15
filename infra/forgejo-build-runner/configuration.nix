{
  config,
  ...
}:
let
  cacheProxyPort = 42000;
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

  sops.secrets.forgejo-build-runner-token = {
    sopsFile = ./secrets/forgejo-build-runner.yaml;
  };

  services.forgejo-runner.instances.build = {
    enable = true;

    settings = {
      runner.labels = [
        # Closest thing to a GitHub-hosted ubuntu runner (~550 MiB compressed)
        "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-24.04"
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

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/forgejo-runner"
      "/var/lib/containers" # podman image cache
      "/var/lib/renovate-cache" # renovate containerbase cache
    ];
  };
}
