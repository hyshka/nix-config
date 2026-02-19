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
  imports = [ (container.mkContainer { name = "wireguard-gateway"; }) ];

  # Enable forwarding & NAT capabilities
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 0;
    "net.ipv6.conf.all.disable_ipv6" = 1;
  };

  # Use systemd-networkd for networking
  networking.useHostResolvConf = false;
  networking.useNetworkd = true;
  # testing only
  environment.systemPackages = [
    pkgs.wireguard-tools
    pkgs.dig
    pkgs.traceroute
    pkgs.tcpdump
  ];

  # Enable systemd-resolved for DNS forwarding to media-download
  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        DNSStubListenerExtra = [ "10.100.0.2" ];
      };
    };
  };

  # WireGuard VPN configuration
  systemd.network = {
    enable = true;

    netdevs."50-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
      };
      wireguardConfig = {
        PrivateKeyFile = config.sops.secrets.wireguard-privatekey.path;
        FirewallMark = 34952; # "0x8888";
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
        {
          Family = "both";
          FirewallMark = 34952; # "0x8888";
          InvertRule = true;
          Table = 1000;
          Priority = 10;
        }
        {
          To = "169.150.196.69/32";
          Priority = 5;
        }
      ];
    };

    networks."51-eth1" = {
      matchConfig.Name = "eth1";
      address = [ "10.100.0.2/24" ];
      networkConfig = {
        IPv4Forwarding = true;
        IPv6Forwarding = false;
      };
    };
  };

  sops.secrets.wireguard-privatekey = {
    sopsFile = ./secrets/wireguard-gateway.yaml;
    owner = "systemd-network";
    group = "systemd-network";
    mode = "0400";
  };

  # Open firewall for web UIs (accessible from incusbr0)
  networking.firewall = {
    allowedTCPPorts = [
      8080 # qBittorrent (forwarded from media-download)
      8085 # SABnzbd (forwarded from media-download)
      9586 # Wireguard exporter (Prometheus)
    ];
    allowedUDPPorts = [ 53 ]; # DNS
    trustedInterfaces = [
      "eth1"
      "wg0"
    ]; # Trust traffic from media-download
    extraCommands = ''
      iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o wg0 -j MASQUERADE
      iptables -A FORWARD -i eth1 -o wg0 -j ACCEPT
      iptables -A FORWARD -i wg0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
    '';
  };
}
