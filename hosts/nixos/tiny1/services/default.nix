{
  imports = [
    ./calibre.nix
    ./docker.nix
    ./media
    ./restic.nix
    ./samba.nix
    ./snapraid.nix
    ./syncthing.nix # TODO: move to incus
    ./caddy.nix # TODO: move to incus
    ./acme.nix
    #./nextcloud.nix # TODO: move to incus
    ./grafana # TODO: move to incus
    ./adguard-home.nix # TODO: move to rpi4
    ./incus.nix
  ];
}
