{ config, ... }:
{
  # WireGuard VPN Gateway for Incus Containers
  #
  # Architecture:
  # - WireGuard (wg0) runs on host tiny1
  # - Containers on vpnbr0 (10.100.0.0/24) route through wg0
  # - Uses ProtonVPN NL#909 (169.150.196.69:51820)
  # - DNS: 10.2.0.1 (ProtonVPN DNS)
  #
  # Container access:
  # - incusbr0 → vpnbr0: ALLOWED (radarr → qbittorrent)
  # - vpnbr0 → incusbr0: BLOCKED for new connections (kill-switch)
  # - vpnbr0 → internet: BLOCKED except via wg0 (kill-switch)

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    # Disable IPv6 only on VPN interfaces to prevent leaks
    "net.ipv6.conf.wg0.disable_ipv6" = 1;
    "net.ipv6.conf.vpnbr0.disable_ipv6" = 1;
  };

  networking.useNetworkd = true;

  systemd.network = {
    enable = true;

    # WireGuard interface
    netdevs."50-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
      };
      wireguardConfig = {
        PrivateKeyFile = config.sops.secrets.wireguard-privatekey.path;
        FirewallMark = 34952; # 0x8888
      };
      wireguardPeers = [
        {
          # ProtonVPN NL#909
          PublicKey = "8x7Y1OT1WRtShqk4lk3KbqpnPftTZLCpVu4VxRT/dzQ=";
          Endpoint = "169.150.196.69:51820";
          AllowedIPs = [ "0.0.0.0/0" ];
          PersistentKeepalive = 25;
          RouteTable = 1000;
        }
      ];
    };

    # WireGuard network configuration
    networks."50-wg0" = {
      matchConfig.Name = "wg0";
      address = [ "10.2.0.2/32" ];
      dns = [ "10.2.0.1" ];
      domains = [ "~." ]; # Route DNS queries through VPN for wg0 interface only

      networkConfig = {
        DNSDefaultRoute = true;
        IPv4Forwarding = true;
      };

      # Policy-based routing rules
      routingPolicyRules = [
        # Priority 5: Keep vpnbr0 subnet local
        {
          To = "10.100.0.0/24";
          Priority = 5;
          Table = "main";
        }

        # Priority 6: VPN endpoint bypass (prevent WireGuard routing loop)
        {
          To = "169.150.196.69/32";
          Priority = 6;
          Table = "main";
        }

        # Priority 7: Keep incusbr0 subnet local
        {
          To = "10.223.27.0/24";
          Priority = 7;
          Table = "main";
        }

        # Priority 10: Route traffic FROM vpnbr0 to VPN table
        {
          From = "10.100.0.0/24";
          Priority = 10;
          Table = 1000;
        }

        # Priority 11: Prevent WireGuard protocol packets from routing through tunnel
        {
          Family = "both";
          FirewallMark = 34952;
          InvertRule = true;
          Table = 1000;
          Priority = 11;
        }
      ];
    };

    # vpnbr0 bridge configuration
    networks."40-vpnbr0" = {
      matchConfig.Name = "vpnbr0";
      networkConfig = {
        IPv4Forwarding = true;
        IPv6Forwarding = false;
      };
    };
  };

  # Secrets
  sops.secrets.wireguard-privatekey = {
    sopsFile = ../secrets.yaml; # Host secrets file
    owner = "systemd-network";
    group = "systemd-network";
    mode = "0400";
  };

  # Firewall configuration
  networking.firewall = {
    # Use "loose" rpfilter for policy routing compatibility
    checkReversePath = "loose";

    # Trust VPN-related interfaces
    trustedInterfaces = [
      "vpnbr0"
      "wg0"
    ];

    # nftables forward rules (inject into NixOS firewall chains)
    extraForwardRules = ''
      # VPN routing rules
      iifname "vpnbr0" oifname "wg0" accept
      iifname "wg0" oifname "vpnbr0" ct state established,related accept

      # Allow incusbr0 → vpnbr0 (e.g., radarr → qbittorrent)
      iifname "incusbr0" oifname "vpnbr0" accept

      # Allow vpnbr0 → incusbr0 ONLY for established connections (responses)
      iifname "vpnbr0" oifname "incusbr0" ct state established,related accept

      # Allow vpnbr0 internal traffic (container-to-container)
      iifname "vpnbr0" oifname "vpnbr0" accept

      # Kill-switch: Drop vpnbr0 → internet (except via wg0 or to local subnets)
      # This prevents VPN leaks if WireGuard goes down
      iifname "vpnbr0" oifname != "wg0" oifname != "vpnbr0" oifname != "incusbr0" drop
    '';
  };

  # NAT configuration using nftables
  networking.nftables.tables.vpn-nat = {
    family = "ip";
    content = ''
      chain postrouting {
        type nat hook postrouting priority 100; policy accept;
        
        # Masquerade traffic from vpnbr0 through VPN
        ip saddr 10.100.0.0/24 oifname "wg0" masquerade
      }

      chain prerouting {
        type nat hook prerouting priority -100; policy accept;
      }
    '';
  };

  # TCP MSS clamping for WireGuard MTU
  networking.nftables.tables.vpn-mangle = {
    family = "ip";
    content = ''
      chain forward {
        type filter hook forward priority -150; policy accept;
        
        # Clamp MSS to WireGuard MTU (1420) to prevent packet fragmentation
        oifname "wg0" tcp flags syn tcp option maxseg size set rt mtu
      }
    '';
  };
}
