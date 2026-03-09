{
  networking = {
    interfaces = {
      "enp37s0" = {
        wakeOnLan.enable = true;
      };
    };
    firewall = {
      allowedUDPPorts = [ 9 ];
    };
  };
}
