{pkgs, ...}: {
  disabledModules = ["virtualisation/incus.nix"];

  imports = [
    ../../../overlays/incus.nix
  ];

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
