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
container.mkContainer {
  name = "media-vpn";
}
// {
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

  # Wireguard VPN configuration (protonvpn)
  networking.wireguard.interfaces.wg0 = {
    privateKeyFile = config.sops.secrets.wireguard-privatekey.path;
    ips = [ "10.2.0.2/32" ];
    extraOptions = {
      DNS = "10.2.0.1";
    };
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
