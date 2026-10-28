{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ../../common/incus-ci.nix ];

  # References
  # - https://github.com/viperML/dotfiles/blob/5002378af7d3e1f898b2eac9ff80ef9512d68587/modules/nixos/incus.nix#L45

  environment.systemPackages = [ pkgs.incus ]; # provides incus-migrate, etc.
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

            "restricted.containers.nesting" = "allow"; # profile: security.nesting
            "restricted.idmap.uid" = "0,274,275,997,998,1000,61654";
            "restricted.idmap.gid" = "0,100,13000";
            # profile: the sops age key is a host path
            "restricted.devices.disk" = "allow";
            "restricted.devices.disk.paths" = "/run/incus-secrets,/mnt/storage";
            "restricted.devices.proxy" = "allow"; # instance: forgejo's ssh proxy
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
            "restricted.idmap.gid" = "0,13000";
            "restricted.devices.disk" = "allow";
            "restricted.devices.disk.paths" = "/run/incus-secrets,/mnt/storage";
            "restricted.devices.proxy" = "allow";
            "restricted.devices.gpu" = "allow";
          };
        }
      ];

      config = {
        "core.https_address" = ":8443";
        "core.metrics_address" = "127.0.0.1:8444";
        # TODO: find a simple way to enable auth
        "core.metrics_authentication" = "false";
        "oidc.client.id" = "e8b1278a-ef80-45d7-844a-2712342e7471";
        "oidc.issuer" = "https://auth.home.hyshka.com";
        "oidc.scopes" = "openid,email,profile";
      };
      networks = [
        {
          name = "incusbr0";
          project = "default";
          type = "bridge";
          description = "Bridge for NixOS LXC containers";
          config = {
            "ipv4.address" = "10.223.27.1/24";
            "ipv4.nat" = "true";
            "ipv6.address" = "fd42:336e:13ec:f27d::1/64";
            "ipv6.nat" = "true";
          };
        }
      ];

      storage_pools = [
        {
          name = "default";
          driver = "dir";
          description = "SSD-backed storage for databases and container state";
          config.source = "/var/lib/incus/storage-pools/default";
        }
        {
          name = "storage";
          driver = "dir";
          description = "HDD-based bulk data for backups, media, etc";
          config.source = "/mnt/storage/incus";
        }
      ];

      profiles = [
        {
          name = "nixos-container";
          project = "default";
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
            persist = {
              type = "disk";
              path = "/persist";
              shift = "true";
              # TODO: this needs to be overridden per-instance and must be reworked
              # e.g. /persist/microvms/<instance_name>
              source = "/persist/microvms/";
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
              source = "/run/incus-secrets/lxc-core-age-key";
            };
          };
        }
        {
          name = "nixos-container";
          project = "lab-default";
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
              source = "/run/incus-secrets/lxc-core-age-key";
            };
          };
        }
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
              source = "/run/incus-secrets/lxc-core-age-key";
            };
          };
        }
      ];
    };
  };

  services.resolved.settings.Resolve = {
    DNS = [ "10.223.27.1" ];
    Domains = [ "~incus" ];
  };

  networking.nftables.enable = true;
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1; # normally incusd sets this, but something in nixos reset it
  users.groups."incus-admin".members = config.users.groups."wheel".members;
  # Incus remote access
  networking.firewall.allowedTCPPorts = [ 8443 ];
  # Enable networking rules after initialization
  # Allowing the entire interface _should_ be safe as incus has its own firewall
  networking.firewall.trustedInterfaces = [ "incusbr0" ];

  # encrypted secret keys for Incus containers
  # provisioned in containers via bind mounts
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
      install -m 0400 ${config.sops.secrets.lxc-core-age-key.path} /run/incus-secrets/lxc-core-age-key
    '';
  };

  # TODO: create a better system for managing idmapped disks
  users.users.root = {
    subUidRanges = [
      # hyshka user
      {
        count = 1;
        startUid = 1000;
      }
      # media-arr container
      {
        startUid = 274;
        count = 1;
      }
      {
        startUid = 275;
        count = 1;
      }
      {
        startUid = 997;
        count = 1;
      }
      {
        startUid = 998;
        count = 1;
      }
      {
        startUid = 61654;
        count = 1;
      }
    ];
    subGidRanges = [
      # users group
      {
        count = 1;
        startGid = 100;
      }
      # mediacenter group
      {
        count = 1;
        startGid = 13000;
      }
    ];
  };

  # Temp fix for "Failed getting os.UserHomeDir(): $HOME is not defined"
  # https://github.com/lxc/incus/issues/2439
  systemd.services.incus.environment = {
    HOME = "/var/lib/incus";
  };

  # Expose Incus metrics on localhost
  # incus config set core.metrics_address "127.0.0.1:8444"
  # Disable metrics auth (NOT RECOMMENDED)
  # incus config set core.metrics_authentication false
}
