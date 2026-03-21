{
  imports = [
    ./calibre.nix
    ./media.nix
    ./restic.nix
    ./samba.nix
    ./snapraid.nix
    ./syncthing.nix
    ./caddy.nix # moved to incus
    ./acme.nix
    #./nextcloud.nix # TODO: move to incus
    ./grafana
    ./adguard-home.nix # TODO: move to rpi4
    ./incus.nix
  ];
}
