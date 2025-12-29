# Expose Samba LXC container to the network
{
  # TODO: Create better pattern for exposing ports from LXC containers
  networking.firewall.allowedTCPPorts = [
    139
    445
  ];
  networking.firewall.allowedUDPPorts = [
    137
    138
  ];
}
