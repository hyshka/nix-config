# Expose Caddy LXC container to the network
{
  # TODO: Create better pattern for exposing ports from LXC containers
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [ 443 ];
}
