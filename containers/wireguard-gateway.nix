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

  # incus network create vpnbr0 ipv4.address=10.100.0.1/24
  # incus config device add wireguard-gateway eth1 nic parent=vpnbr0
  # incus config device add media-download eth0 nic parent=vpnbr0

  # Enable forwarding & NAT capabilities
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 0;
    "net.ipv6.conf.all.disable_ipv6" = 1;
  };

  # Use systemd-networkd for networking
  networking.useHostResolvConf = false;
  networking.useNetworkd = true;
  environment.systemPackages = [
    pkgs.wireguard-tools
  ];

  # Enable systemd-resolved for DNS forwarding to media-download
  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        DNSStubListenerExtra = [ "10.100.0.2" ];
        FallbackDNS = null;
        LLMNR = "no";
        MulticastDNS = "no";
        DNSOverTLS = "no";
        CacheFromLocalhost = "no";
      };
    };
  };

  # TODO: Rate-limit DNS requests
  #networking.firewall.extraCommands = ''
  #  iptables -A INPUT -p udp --dport 53 -m state --state NEW -m recent --set
  #  iptables -A INPUT -p udp --dport 53 -m state --state NEW -m recent --update --seconds 1 --hitcount 10 -j DROP
  #'';

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

    networks."10-eth0" = {
      matchConfig.Name = "eth0";
      # Allow DHCP for management connectivity
      networkConfig = {
        DHCP = "yes";
      };
      # Reject DNS from DHCP - only use VPN DNS
      dhcpV4Config = {
        UseDNS = false;
        UseRoutes = true;
        UseDomains = false;
      };
      dhcpV6Config = {
        UseDNS = false;
      };
      ipv6AcceptRAConfig = {
        UseDNS = false;
      };
      # Explicitly no DNS configuration
      dns = [ ];
      domains = [ ];
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
      # TODO: add exporter
      #9586 # Wireguard exporter (Prometheus)
    ];
    allowedUDPPorts = [ 53 ]; # DNS
    trustedInterfaces = [
      "eth1"
      "wg0"
    ]; # Trust traffic from media-download
    extraCommands = ''
      # NAT for outbound VPN traffic
      iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o wg0 -j MASQUERADE

      # Port forwarding from wireguard-gateway to media-download
      iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 8080 -j DNAT --to-destination 10.100.0.3:8080
      iptables -A FORWARD -i eth0 -o eth1 -p tcp --dport 8080 -d 10.100.0.3 -j ACCEPT
      iptables -A FORWARD -i eth1 -o eth0 -p tcp --sport 8080 -s 10.100.0.3 -j ACCEPT

      iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 8085 -j DNAT --to-destination 10.100.0.3:8085
      iptables -A FORWARD -i eth0 -o eth1 -p tcp --dport 8085 -d 10.100.0.3 -j ACCEPT
      iptables -A FORWARD -i eth1 -o eth0 -p tcp --sport 8085 -s 10.100.0.3 -j ACCEPT

      # VPN forwarding rules
      iptables -A FORWARD -i eth1 -o wg0 -j ACCEPT
      iptables -A FORWARD -i wg0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
    '';
  };
}
