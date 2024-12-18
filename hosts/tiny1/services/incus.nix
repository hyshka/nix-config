{
  virtualisation.incus.enable = true;
  networking.nftables.enable = true;
  users.users.hyshka.extraGroups = ["incus-admin"];
  # Enable networking rules after initialization
  networking.firewall.interfaces.incusbr0.allowedTCPPorts = [
    53
    67
  ];
  networking.firewall.interfaces.incusbr0.allowedUDPPorts = [
    53
    67
  ];

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
