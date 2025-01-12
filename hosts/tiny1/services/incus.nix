{pkgs, ...}: {
  disabledModules = ["virtualisation/incus.nix"];

  imports = [
    ../../../overlays/incus.nix
  ];

  # References
  # - https://github.com/viperML/dotfiles/blob/5002378af7d3e1f898b2eac9ff80ef9512d68587/modules/nixos/incus.nix#L45

  environment.systemPackages = [pkgs.incus]; # provides incus-migrate, etc.
  virtualisation.incus = {
    enable = true;
    package = pkgs.incus; # use latest instead of LTS
  };
  networking.nftables.enable = true;
  users.users.hyshka.extraGroups = ["incus-admin"];
  # Incus remote access
  networking.firewall.allowedTCPPorts = [8443];
  # Enable networking rules after initialization
  # Allowing the entire interface _should_ be safe as incus has its own firewall
  networking.firewall.trustedInterfaces = ["incusbr*"];
  #networking.firewall.interfaces.incusbr0.allowedTCPPorts = [
  #  53
  #  67

  # Expose Incus metrics on localhost
  # incus config set core.metrics_address "127.0.0.1:8444"
  # Disable metrics auth (NOT RECOMMENDED)
  # incus config set core.metrics_authentication false

  #  8123 # hass
  #];
  #networking.firewall.interfaces.incusbr0.allowedUDPPorts = [
  #  53
  #  67
  #];

  # incus admin init
  #yaml = ''
  #  config: {}
  #  networks:
  #  - config:
  #      ipv4.address: auto
  #      ipv6.address: auto
  #    description: ""
  #    name: incusbr0
  #    type: ""
  #    project: default
  #  storage_pools:
  #  - config: {}
  #    description: ""
  #    name: default
  #    driver: dir
  #  profiles:
  #  - config: {}
  #    description: ""
  #    devices:
  #      eth0:
  #        name: eth0
  #        network: incusbr0
  #        type: nic
  #      root:
  #        path: /
  #        pool: default
  #        type: disk
  #    name: default
  #  projects: []
  #  cluster: null
  #'';
}
