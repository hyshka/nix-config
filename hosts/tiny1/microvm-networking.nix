{...}: let
  netinterface = "enp0s31f6";
in {
  # https://astro.github.io/microvm.nix/advanced-network.html#a-bridge-to-link-tap-interfaces
  systemd.network = {
    networks = {
      "10-virbr0" = {
        matchConfig.Name = "virbr0";
        networkConfig = {
          Address = "192.168.0.1/24";
          IPv6SendRA = true;
        };
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

  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = netinterface;
    internalInterfaces = ["virbr0"];
  };
}
