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

  # disable IPv6 to prevent DNS leaks
  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = 0;
    "net.ipv6.conf.all.disable_ipv6" = 1;
  };

  # Use systemd-networkd for networking
  networking.useHostResolvConf = false;
  networking.useNetworkd = true;

  # Disable fallback DNS to prevent leaks when VPN is slow/down
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

  systemd.network.networks."50-eth0" = {
    matchConfig.Name = "eth0";
    address = [ "10.100.0.3/24" ];
    routes = [
      {
        Destination = "0.0.0.0/0";
        Gateway = "10.100.0.2";
      }
    ];
    dns = [ "10.100.0.2" ]; # Use wireguard-gateway as DNS forwarder
    domains = [ "~." ];
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
