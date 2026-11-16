{
  config,
  pkgs,
  ...
}:
let
  cacheProxyPort = 42000;
  cacheDir = "/var/lib/forgejo-cache";
  cacheStore = "${cacheDir}/binary-cache";
in
{
  # A full VM, so podman can run job containers without LXC nesting. It carries
  # only the untrusted docker label; the trusted apply/drift jobs run on Starship

  # Let job containers reach the runner's cache proxy at host.containers.internal.
  networking.firewall.interfaces."podman+".allowedTCPPorts = [ cacheProxyPort ];

  # Renovate's job container runs as the containerbase `ubuntu` user (uid
  # 12021), which needs to write its cache volume.
  systemd.tmpfiles.rules = [
    "d ${cacheDir}/renovate 0770 12021 root -"
    "d ${cacheStore} 0755 root root -"
    "D /var/lib/containers 0755 root root -"
  ];

  virtualisation.podman.enable = true;
  virtualisation.podman.autoPrune.enable = true;
  virtualisation.containers.storage.rootful.settings.storage.graphroot = "${cacheDir}/containers";

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
        envs.NIX_CONFIG = ''
          substituters = file:///nix-cache https://cache.nixos.org
          require-sigs = false
        '';
      };

      server.connections.default = {
        url = "https://code.home.hyshka.com/";
        uuid = "f265f0e9-a15d-498b-ae84-9a54ad70e180";
      };

      container = {
        # Cap job containers. Keep the safe defaults for privileged/network.
        options = "--memory=3g --cpus=2 --volume ${cacheStore}:/nix-cache";
        valid_volumes = [
          "${cacheDir}/renovate"
          "${cacheStore}"
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

  systemd.services.forgejo-cache-gc = {
    description = "Bound the disposable Forgejo runner caches";
    script = ''
      if [ -n "$(${pkgs.podman}/bin/podman ps -q)" ]; then
        echo "skipping cache maintenance: a job container is running" >&2
        exit 0
      fi

      for repo in $(${pkgs.podman}/bin/podman images --format '{{.Repository}}' | ${pkgs.gnugrep}/bin/grep -vx '<none>' | ${pkgs.coreutils}/bin/sort -u); do
        tags=$(${pkgs.podman}/bin/podman images --format '{{.Tag}}' "$repo" | ${pkgs.gnugrep}/bin/grep -vx '<none>' || true)
        keep=$(printf '%s\n' "$tags" | ${pkgs.coreutils}/bin/sort -V | ${pkgs.coreutils}/bin/tail -n 1)
        for tag in $tags; do
          [ "$tag" = "$keep" ] || ${pkgs.podman}/bin/podman rmi --force "$repo:$tag" || true
        done
      done

      if [ -d ${cacheStore} ] && [ "$(${pkgs.coreutils}/bin/du -sm ${cacheStore} | ${pkgs.coreutils}/bin/cut -f1)" -ge 2048 ]; then
        ${pkgs.findutils}/bin/find ${cacheStore} -mindepth 1 -maxdepth 1 -exec rm -rf {} + || true
      fi
    '';
    serviceConfig.Type = "oneshot";
  };

  systemd.timers.forgejo-cache-gc = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 04:15:00";
      Persistent = true;
    };
  };

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/forgejo-runner"
    ];
  };
}
