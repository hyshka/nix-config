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

  # Disable IPv6 to prevent leaks
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 0;
    "net.ipv6.conf.all.disable_ipv6" = 1;
  };

  environment.systemPackages = [
    pkgs.wireguard-tools
  ];

  # NixOS firewall will block wg traffic because of rpfilter
  networking.firewall.checkReversePath = "loose";

  networking.useNetworkd = true; # only use networkd
  systemd.network = {
    enable = true;

    netdevs."50-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
      };
      wireguardConfig = {
        PrivateKeyFile = config.sops.secrets.wireguard-privatekey.path;
        FirewallMark = 42;
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
          RouteTable = 1000;
        }
      ];
    };

    networks."50-wg0" = {
      matchConfig.Name = "wg0";
      address = [
        "10.2.0.2/32"
      ];
      dns = [
        "10.2.0.1"
      ];
      domains = [ "~." ];
      networkConfig = {
        DNSDefaultRoute = true;
      };
      routingPolicyRules = [
        # Priority 5: VPN endpoint bypass (prevent WireGuard routing loop)
        {
          To = "169.150.196.69/32";
          Priority = 5;
        }
        # Priority 9: Keep local subnet traffic local (DNS, ping, web UIs)
        # This prevents 10.100.0.0/24 traffic from being routed through VPN
        #{
        #  To = "10.100.0.0/24";
        #  Priority = 9;
        #}
        # Priority 10: Everything else without fwmark goes to VPN
        {
          Family = "both";
          FirewallMark = 42;
          InvertRule = true;
          Table = 1000;
          Priority = 10;
        }
      ];
    };

    #networks."99-lxc-veth-default-dhcp" = {
    #  matchConfig.Name = "eth0";
    #  networkConfig = {
    #  };
    #};
  };

  # Disable DNS fallback (kill-switch for DNS)
  networking.useHostResolvConf = false; # only use resolved
  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        FallbackDNS = null;
        LLMNR = "no";
        MulticastDNS = "no";
        DNSOverTLS = "no";
      };
    };
  };

  sops.secrets.wireguard-privatekey = {
    sopsFile = ./secrets/media-download.yaml;
    owner = "systemd-network";
    group = "systemd-network";
    mode = "0400";
  };

  # Create mediacenter group matching host GID
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

  services.sabnzbd = {
    enable = true;
    openFirewall = true;
    user = "sabnzbd";
    group = "mediacenter";
    secretFiles = [ config.sops.secrets.sabnzbd-secretsFile.path ];
    settings = {
      misc = {
        # Network
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
        # Empty whitelist allows all hosts (safe - network already isolated to vpnbr0)
        host_whitelist = "";

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

  nixpkgs = {
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "unrar"
      ];
  };

  users.users.qbittorrent.extraGroups = [ "mediacenter" ];
  users.users.sabnzbd.extraGroups = [ "mediacenter" ];

  # Scheduled pause/unpause for qBittorrent (for backup windows)
  systemd.services.qbittorrent-pause = {
    description = "Pause qBittorrent for backup window";
    script = "${pkgs.systemd}/bin/systemctl stop qbittorrent";
    startAt = "*-*-* 00:55:00";
  };

  systemd.services.qbittorrent-unpause = {
    description = "Unpause qBittorrent after backup window";
    script = "${pkgs.systemd}/bin/systemctl start qbittorrent || true";
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
