{
  # Open port to sync with koreader
  # TODO: Create better pattern for exposing ports from LXC containers
  networking.firewall.allowedTCPPorts = [ 8083 ];
}
