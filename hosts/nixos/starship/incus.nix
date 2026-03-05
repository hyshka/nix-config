{ pkgs, config, ... }:
{
  environment.systemPackages = [ pkgs.incus ];
  virtualisation.incus = {
    enable = true;
    package = pkgs.incus; # use latest instead of LTS
  };
  networking.nftables.enable = true;
  users.groups."incus-admin".members = config.users.groups."wheel".members;
  # Incus remote access
  networking.firewall.allowedTCPPorts = [ 8443 ];
  # Enable networking rules after initialization
  # Allowing the entire interface _should_ be safe as incus has its own firewall
  networking.firewall.trustedInterfaces = [ "incusbr0" ];

  # Expose Open-WebUI to tailscale0
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 8080 ];
}
