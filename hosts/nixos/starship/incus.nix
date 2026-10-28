{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ../common/incus-ci.nix ];

  environment.systemPackages = [ pkgs.incus ];
  virtualisation.incus = {
    enable = true;
    package = pkgs.incus; # use latest instead of LTS
    ui.enable = true;
    # Platform resources live here, not in infra: nix-config owns the host, tofu owns the workloads.
    # Re-applied on every boot; existing entities merge; removed entries are retained.
    preseed = {
      projects = [
        {
          name = "lab-default";
          config = {
            restricted = "true";
            "restricted.storage-pools.access" = "default";
            "features.images" = "true"; # own image namespace
            "features.profiles" = "true"; # required
            "features.networks" = "false"; # share the default project's networks

            "restricted.containers.nesting" = "allow";
            "restricted.idmap.uid" = "0";
            "restricted.idmap.gid" = "0";
            "restricted.devices.disk" = "allow";
            "restricted.devices.disk.paths" = "/run/incus-secrets";
            "restricted.devices.proxy" = "allow";
          };
        }
        {
          name = "lab-gpu";
          config = {
            restricted = "true";
            "restricted.storage-pools.access" = "default";
            "features.images" = "true";
            "features.profiles" = "true";
            "features.networks" = "false";

            "restricted.containers.nesting" = "allow";
            "restricted.idmap.uid" = "0";
            "restricted.idmap.gid" = "0";
            "restricted.devices.disk" = "allow";
            "restricted.devices.disk.paths" = "/run/incus-secrets";
            "restricted.devices.proxy" = "allow";
            "restricted.devices.gpu" = "allow";
            "restricted.devices.unix-char" = "allow"; # ai: /dev/kfd, not path-scoped by Incus
          };
        }
      ];

      config = {
        "core.https_address" = ":8443";
        "core.metrics_address" = "0.0.0.0:8444";
        # TODO: find a simple way to enable auth
        "core.metrics_authentication" = "false";
      };
      networks = [
        {
          name = "incusbr0";
          project = "default";
          type = "bridge";
          description = "Bridge for NixOS LXC containers";
          config = {
            "ipv4.address" = "10.166.156.1/24";
            "ipv4.nat" = "true";
            "ipv6.address" = "fd42:6d20:ae61:7455::1/64";
            "ipv6.nat" = "true";
          };
        }
      ];

      profiles = [
        {
          name = "default";
          project = "lab-default";
          description = "Default profile for lab-default workloads";
          devices = {
            eth0 = {
              type = "nic";
              network = "incusbr0";
            };
            root = {
              type = "disk";
              path = "/";
              pool = "default";
            };
          };
        }
        {
          name = "default";
          project = "lab-gpu";
          description = "Default profile for lab-gpu workloads";
          devices = {
            eth0 = {
              type = "nic";
              network = "incusbr0";
            };
            root = {
              type = "disk";
              path = "/";
              pool = "default";
            };
          };
        }
        {
          name = "nixos-container";
          project = "lab-gpu";
          description = "Standard profile for NixOS LXC containers";
          config = {
            "raw.idmap" = "both 0 0";
            "security.nesting" = "true";
          };
          devices = {
            eth0 = {
              type = "nic";
              network = "incusbr0";
            };
            root = {
              type = "disk";
              path = "/";
              pool = "default";
            };
            sops-age-key = {
              type = "disk";
              path = "/var/lib/sops-nix/key.txt";
              "raw.mount.options" = "uid=0,gid=0";
              readonly = "true";
              source = "/run/incus-secrets/lxc-ai-age-key";
            };
          };
        }
      ];
    };
  };

  networking.nftables.enable = true;
  users.groups."incus-admin".members = config.users.groups."wheel".members;
  # Incus remote access
  networking.firewall.allowedTCPPorts = [
    8443
    8444
  ];
  # Enable networking rules after initialization
  # Allowing the entire interface _should_ be safe as incus has its own firewall
  networking.firewall.trustedInterfaces = [ "incusbr0" ];

  # Expose Open-WebUI and Ollama to tailscale0
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    8080
    11434
  ];

  # encrypted secret keys for Incus containers
  # provisioned in containers via bind mounts
  sops.secrets.lxc-ai-age-key = { };
  sops.secrets.lxc-core-age-key = { };

  # Incus restricted disk source rejects sops-nix symlinks.
  # Copy real secrets in the isolated dir.
  systemd.services.incus-secrets = {
    wantedBy = [ "multi-user.target" ];
    after = lib.optional config.sops.useSystemdActivation "sops-install-secrets.service";
    requires = lib.optional config.sops.useSystemdActivation "sops-install-secrets.service";
    before = [ "incus.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      RuntimeDirectory = "incus-secrets";
      RuntimeDirectoryMode = "0700";
    };
    script = ''
      install -m 0400 ${config.sops.secrets.lxc-ai-age-key.path} /run/incus-secrets/lxc-ai-age-key
      install -m 0400 ${config.sops.secrets.lxc-core-age-key.path} /run/incus-secrets/lxc-core-age-key
    '';
  };
}
