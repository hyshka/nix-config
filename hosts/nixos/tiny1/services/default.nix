{
  imports = [
    ./media.nix
    ./restic.nix
    ./samba.nix
    ./snapraid.nix
    ./syncthing.nix
    ./caddy.nix
    ./acme.nix
    ./grafana
    ./adguard-home.nix # TODO: move to rpi4
    ./incus.nix
  ];
}
