{...}: let
  netinterface = "enp0s31f6";
in {
  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = [netinterface "vm-*"];
        networkConfig = {
          Bridge = "br0";
        };
      };
      "10-lan-bridge" = {
        matchConfig.Name = "br0";
        networkConfig = {
          Address = ["10.0.0.240/24"];
          Gateway = "10.0.0.1";
          DNS = ["10.0.0.240"];
          IPv6AcceptRA = true;
        };
        linkConfig.RequiredForOnline = "routable";
      };
    };
    netdevs = {
      "br0" = {
        netdevConfig = {
          Name = "br0";
          Kind = "bridge";
        };
      };
    };
  };
  # Now all host connections with be on br0
  # If you lets say want to ssh into the server, the ip would be 192.168.1.2
}
