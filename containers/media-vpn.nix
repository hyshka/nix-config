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
  imports = [ (container.mkContainer { name = "media-vpn"; }) ];

  # Open firewall for qBittorrent and SABnzbd web UIs
  networking.firewall.allowedTCPPorts = [
    8080 # qBittorrent
    8085 # SABnzbd
    9586 # Wireguard exporter (Prometheus)
  ];

  # Create mediacenter group matching host GID for storage access
  users.groups.mediacenter = {
    gid = 13000;
  };

  sops.secrets.wireguard-privatekey = {
    sopsFile = ./secrets/media-vpn.yaml;
    owner = "root";
    mode = "0400";
  };

  sops.secrets.sabnzbd-secretsFile = {
    sopsFile = ./secrets/media-vpn.yaml;
    owner = "sabnzbd";
  };

  # Wireguard VPN configuration (protonvpn)
  networking.wireguard.interfaces.wg0 = {
    privateKeyFile = config.sops.secrets.wireguard-privatekey.path;
    ips = [ "10.2.0.2/32" ];
    peers = [
      {
        # NL#909
        publicKey = "8x7Y1OT1WRtShqk4lk3KbqpnPftTZLCpVu4VxRT/dzQ=";
        endpoint = "169.150.196.69:51820";
        allowedIPs = [ "0.0.0.0/0" ];
        persistentKeepalive = 25;
      }
    ];
  };

  # Network namespace setup for routing qBittorrent and SABnzbd through VPN
  # This creates a separate network namespace where all traffic goes through wg0
  systemd.services.vpn-netns = {
    description = "VPN Network Namespace for Downloaders";
    after = [ "wireguard-wg0.service" ];
    requires = [ "wireguard-wg0.service" ];
    before = [
      "qbittorrent.service"
      "sabnzbd.service"
    ];
    wantedBy = [ "multi-user.target" ];

    path = with pkgs; [
      iproute2
      wireguard-tools
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;

      ExecStart = pkgs.writeShellScript "setup-vpn-ns" ''
        # Create network namespace
        ip netns add vpn || true

        # Move wg0 into the namespace
        ip link set wg0 netns vpn

        # Set up networking in the namespace
        ip -n vpn link set lo up
        ip -n vpn link set wg0 up
        ip -n vpn route add default dev wg0

        # Configure DNS for the namespace
        # protonvpn DNS server
        mkdir -p /etc/netns/vpn
        echo "nameserver 10.2.0.1" > /etc/netns/vpn/resolv.conf
      '';

      ExecStop = "${pkgs.iproute2}/bin/ip netns del vpn || true";
    };
  };

  services.qbittorrent = {
    enable = true;
    openFirewall = false; # We handle firewall manually
    user = "qbittorrent";
    group = "mediacenter";
    webuiPort = 8080;
    profileDir = "/var/lib/qbittorrent";

    # Additional qBittorrent configuration can be set here
    # serverConfig = {
    #   Preferences = {
    #     WebUI = {
    #       AlternativeUIEnabled = false;
    #     };
    #   };
    # };
  };

  systemd.services.qbittorrent = {
    after = [ "vpn-netns.service" ];
    requires = [ "vpn-netns.service" ];
    # Route through VPN namespace
    serviceConfig.NetworkNamespacePath = "/var/run/netns/vpn";
  };

  services.sabnzbd = {
    enable = true;
    user = "sabnzbd";
    group = "mediacenter";
    secretFiles = [ config.sops.secrets.sabnzbd-secretsFile.path ];
    settings = {
      misc = {
        # Network
        host = "::";
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

  nixpkgs = {
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        # Explicity add unfree packages for sabnzdb
        "unrar"
      ];
  };

  systemd.services.sabnzbd = {
    after = [ "vpn-netns.service" ];
    requires = [ "vpn-netns.service" ];
    # Route through VPN namespace
    serviceConfig.NetworkNamespacePath = "/var/run/netns/vpn";
  };

  # Add users to mediacenter group
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
