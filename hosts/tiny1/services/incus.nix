{ pkgs, ... }:
{
  # References
  # - https://github.com/viperML/dotfiles/blob/5002378af7d3e1f898b2eac9ff80ef9512d68587/modules/nixos/incus.nix#L45

  environment.systemPackages = [ pkgs.incus ]; # provides incus-migrate, etc.
  virtualisation.incus = {
    enable = true;
    package = pkgs.incus; # use latest instead of LTS
    ui.enable = true;
  };
  networking.nftables.enable = true;
  users.users.hyshka.extraGroups = [ "incus-admin" ];
  # Incus remote access
  networking.firewall.allowedTCPPorts = [ 8443 ];
  # Enable networking rules after initialization
  # Allowing the entire interface _should_ be safe as incus has its own firewall
  networking.firewall.trustedInterfaces = [ "incusbr*" ];

  # TODO: create a better system for managing idmapped disks
  users.users.root = {
    subUidRanges = [
      # hyshka user
      {
        count = 1;
        startUid = 1000;
      }
    ];
    subGidRanges = [
      # users group
      {
        count = 1;
        startGid = 100;
      }
      # mediacenter group
      {
        count = 1;
        startGid = 13000;
      }
    ];
  };

  # Temp fix for "Failed getting os.UserHomeDir(): $HOME is not defined"
  # https://github.com/lxc/incus/issues/2439
  systemd.services.incus.environment = {
    HOME = "/var/lib/incus";
  };

  # Expose Incus metrics on localhost
  # incus config set core.metrics_address "127.0.0.1:8444"
  # Disable metrics auth (NOT RECOMMENDED)
  # incus config set core.metrics_authentication false

  # TODO: set as preseed
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
