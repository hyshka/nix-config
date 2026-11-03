# Expose Samba LXC container to the network
{
  networking.firewall.allowedTCPPorts = [
    139
    445
  ];
  networking.firewall.allowedUDPPorts = [
    137
    138
  ];
}
