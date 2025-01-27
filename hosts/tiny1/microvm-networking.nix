{...}: let
  netinterface = "enp0s31f6";
in {
  # https://astro.github.io/microvm.nix/advanced-network.html#a-bridge-to-link-tap-interfaces
  systemd.network = {
    networks = {
      "10-virbr0" = {
        matchConfig.Name = "virbr0";
        networkConfig = {
          DHCPServer = true;
          IPv6SendRA = true;
        };
        addresses = [
          {
            Address = "10.1.0.1/24";
          }
          {
            Address = "fd12:3456:789a::1/64";
          }
        ];
        # https://github.com/astro/microvm.nix/blob/main/examples/microvms-host.nix#L111
        dhcpServerStaticLeases = [
          {
            MACAddress = "02:00:00:00:00:02";
            Address = "10.1.0.2";
          }
        ];
        ipv6Prefixes = [
          {
            Prefix = "fd12:3456:789a::/64";
          }
        ];
      };
      "11-virbr0" = {
        matchConfig.Name = "vm-*";
        networkConfig.Bridge = "virbr0";
      };
    };
    netdevs = {
      "10-virbr0" = {
        netdevConfig = {
          Name = "virbr0";
          Kind = "bridge";
        };
      };
    };
  };

  networking.firewall.allowedUDPPorts = [67];
  networking.nat = {
    enable = true;
    enableIPv6 = true;
    #externalInterface = netinterface;
    internalInterfaces = ["virbr0"];
  };
}
