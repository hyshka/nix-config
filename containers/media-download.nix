{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  container = import ./default.nix { inherit lib inputs; };
in
{
  imports = [ (container.mkContainer { name = "media-download"; }) ];

  # Disable rp_filter to allow return traffic from VPN via eth0.
  # Per-interface entries are omitted: net.ipv4.conf.all overrides all interfaces.
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.rp_filter" = 0;
    "net.ipv4.conf.default.rp_filter" = 0;
    # Belt-and-suspenders: also disable IPv6 at the kernel level.
    # The primary IPv6 block is at the networkd layer (LinkLocalAddressing/IPv6AcceptRA).
    "net.ipv6.conf.all.disable_ipv6" = 1;
  };

  environment.systemPackages = [
    pkgs.wireguard-tools
  ];

  # NixOS firewall rpfilter chain must be loose to allow return traffic
  # from the VPN peer arriving on eth0 while routing via wg0.
  networking.firewall.checkReversePath = "loose";

  systemd.network = {
    netdevs."50-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
      };
      wireguardConfig = {
        PrivateKeyFile = config.sops.secrets.wireguard-privatekey.path;
      };
      wireguardPeers = [
        {
          # ProtonVPN NL#909
          PublicKey = "8x7Y1OT1WRtShqk4lk3KbqpnPftTZLCpVu4VxRT/dzQ=";
          Endpoint = "169.150.196.69:51820";
          AllowedIPs = [
            "0.0.0.0/0"
          ];
          PersistentKeepalive = 25;
        }
      ];
    };

    networks."50-wg0" = {
      matchConfig.Name = "wg0";
      address = [ "10.2.0.2/32" ];
      dns = [ "10.2.0.1" ];
      domains = [ "~." ];
      networkConfig = {
        DNSDefaultRoute = true;
        DefaultRouteOnDevice = true;
        # wg0 is a point-to-point tunnel; no link-local addressing needed.
        LinkLocalAddressing = "no";
      };
    };

    # Only use VPN DNS; suppress all DHCP-provided DNS and routes.
    networks."99-lxc-veth-default-dhcp" = {
      matchConfig.Name = "eth0";
      networkConfig = {
        # IPv4 DHCP only — overrides lxc-container.nix's DHCP=yes to disable
        # DHCPv6 that would otherwise be enabled alongside LinkLocalAddressing=no.
        DHCP = lib.mkForce "ipv4";
        # Disable IPv6 at the networkd layer — prevents addresses being assigned
        # before the kernel sysctl can take effect, and kills DHCPv6/RA entirely.
        LinkLocalAddressing = "no";
        IPv6AcceptRA = false;
      };
      dhcpV4Config = {
        UseDNS = false;
        UseRoutes = false; # Only want the local subnet route; default via wg0.
        UseDomains = false;
      };
      # DHCPv6 and RA are fully suppressed by LinkLocalAddressing=no and
      # IPv6AcceptRA=false above; no need to configure them further.
      # Route VPN endpoint through eth0 to prevent a routing loop:
      # without this, WireGuard's own encrypted UDP traffic would be sent
      # back into wg0 instead of out to the internet.
      routes = [
        {
          # GatewayOnLink: gateway is on-link even without a static address on eth0
          Destination = "169.150.196.69/32";
          Gateway = "10.223.27.1";
          GatewayOnLink = true;
        }
      ];
    };
  };

  # Ensure systemd-networkd waits for secrets before creating the wg0 netdev,
  # which needs the private key file at /run/secrets/wireguard-privatekey.
  systemd.services.systemd-networkd = {
    wants = [ "sops-install-secrets.service" ];
    after = [ "sops-install-secrets.service" ];
  };

  # Only use VPN DNS; no fallback (DNS kill-switch).
  networking.useHostResolvConf = false;
  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        FallbackDNS = "";
        LLMNR = "no";
        MulticastDNS = "no";
        DNSOverTLS = "no";
      };
    };
  };

  sops.secrets.wireguard-privatekey = {
    sopsFile = ./secrets/media-download.yaml;
    owner = "root";
    group = "systemd-network";
    mode = "0440";
  };

  # Create mediacenter group matching host GID for shared storage access.
  users.groups.mediacenter = {
    gid = 13000;
  };

  sops.secrets.sabnzbd-secretsFile = {
    sopsFile = ./secrets/media-download.yaml;
    owner = "sabnzbd";
  };

  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    user = "qbittorrent";
    group = "mediacenter";
    webuiPort = 8080;
    profileDir = "/var/lib/qbittorrent";
    # TODO: alternate Vue WebUI
  };

  # Ensure qbittorrent only starts once wg0 is routable so its interface
  # binding (Session\Interface=wg0) is satisfied and torrent traffic can't
  # leak over eth0. systemd-networkd-wait-online@wg0 blocks until networkd
  # reports wg0 as routable, regardless of the global --any wait-online.
  systemd.services.qbittorrent = {
    wants = [
      "network-online.target"
      "systemd-networkd-wait-online@wg0.service"
    ];
    after = [
      "network-online.target"
      "systemd-networkd-wait-online@wg0.service"
    ];
  };

  services.sabnzbd = {
    enable = true;
    openFirewall = true;
    user = "sabnzbd";
    group = "mediacenter";
    # Opt into the declarative settings behaviour introduced in NixOS 26.05.
    # Without this, stateVersion < 26.05 causes configFile to default to the
    # legacy path and all settings below are silently ignored.
    configFile = null;
    # Keep the ini writable so sabnzbd can persist runtime state (queue,
    # history) and the web UI remains fully functional.
    allowConfigWrite = true;
    secretFiles = [ config.sops.secrets.sabnzbd-secretsFile.path ];
    settings = {
      misc = {
        # Bind to all interfaces so the web UI is reachable from the LAN.
        # Outbound connections (Usenet downloads) go through wg0 regardless,
        # because all traffic is routed via the WireGuard default route.
        host = "0.0.0.0";
        port = 8085;

        # Performance
        bandwidth_perc = 80;
        bandwidth_max = "120M";
        cache_limit = "1G";

        # Directories
        download_dir = "/data/usenet/incomplete";
        complete_dir = "/data/usenet/complete";

        # Processing
        flat_unpack = 1;
        no_dupes = 4;
        no_smart_dupes = 4;
        deobfuscate_final_filenames = 1;

        # Schedule (pause for backup window)
        schedlines = "1 55 0 1234567 pause_all , 1 0 2 1234567 resume ";

        # Categories
        tv_categories = "tv,";
        movie_categories = "movies,";

        # Allowlist for access
        host_whitelist = "localhost, sabnzbd.home.hyshka.com";

        # History
        history_limit = 10;
        history_retention_option = "all";
        history_retention_number = 1;
      };

      servers = {
        "news.usenetexpress.com" = {
          name = "news.usenetexpress.com";
          displayname = "news.usenetexpress.com";
          host = "news.usenetexpress.com";
          port = 563;
          connections = 50;
          ssl_verify = "strict";
          required = true;
        };
      };

      categories = {
        "*" = {
          name = "*";
          order = 0;
          pp = 3;
          script = "None";
        };
        movies = {
          name = "movies";
          order = 1;
          dir = "movies";
          priority = -100;
        };
        tv = {
          name = "tv";
          order = 2;
          dir = "tv";
          priority = -100;
        };
        audio = {
          name = "audio";
          order = 3;
          dir = "audio";
          priority = -100;
        };
        software = {
          name = "software";
          order = 4;
          dir = "software";
          priority = -100;
        };
        books = {
          name = "books";
          order = 5;
          dir = "books";
          priority = -100;
        };
      };

      ntfosd.ntfosd_enable = false;
    };
  };

  # Ensure sabnzbd only starts once wg0 is routable so Usenet downloads
  # go through the VPN and can't leak over the cleartext path.
  systemd.services.sabnzbd = {
    wants = [
      "network-online.target"
      "systemd-networkd-wait-online@wg0.service"
    ];
    after = [
      "network-online.target"
      "systemd-networkd-wait-online@wg0.service"
    ];
  };

  nixpkgs = {
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "unrar"
      ];
  };

  # Scheduled pause/unpause for qBittorrent (for backup windows).
  systemd.services.qbittorrent-pause = {
    description = "Pause qBittorrent for backup window";
    script = "${pkgs.systemd}/bin/systemctl stop qbittorrent";
    startAt = "*-*-* 00:55:00";
  };

  systemd.services.qbittorrent-unpause = {
    description = "Unpause qBittorrent after backup window";
    script = "${pkgs.systemd}/bin/systemctl start qbittorrent";
    startAt = "*-*-* 02:00:00";
  };

  # Persist service data
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/qbittorrent"
      "/var/lib/sabnzbd"
    ];
  };
}
