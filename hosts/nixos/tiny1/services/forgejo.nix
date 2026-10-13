# Expose the Forgejo LXC container's built-in SSH server to the network
{
  networking.firewall.allowedTCPPorts = [ 2222 ];
}
