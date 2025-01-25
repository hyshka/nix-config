{...}: let
  netinterface = "enp0s31f6";
in {
  networking.useNetworkd = true;
  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = [netinterface "vm-*"];
        networkConfig = {
          Bridge = "vmbr0";
        };
      };
      "10-lan-bridge" = {
        matchConfig.Name = "vmbr0";
        networkConfig = {
          Address = ["192.168.1.2/24" "2001:db8::a/64"];
          Gateway = "192.168.1.1";
          DNS = ["192.168.1.1"];
          IPv6AcceptRA = true;
        };
        linkConfig.RequiredForOnline = "routable";
      };
    };
    netdevs = {
      "vmbr0" = {
        netdevConfig = {
          Name = "vmbr0";
          Kind = "bridge";
        };
      };
    };
  };
  # Now all host connections with be on vmbr0
  # If you lets say want to ssh into the server, the ip would be 192.168.1.2
}
