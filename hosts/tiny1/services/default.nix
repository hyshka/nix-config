{
  imports = [
    ./calibre.nix
    ./docker.nix
    #./home-assistant.nix
    ./homepage.nix
    ./media
    #./microbin.nix
    ./ntfy.nix
    ./restic.nix
    ./samba.nix
    ./snapraid.nix
    ./syncthing.nix
    #./silverbullet.nix
    ./caddy.nix
    ./acme.nix
    #./nextcloud.nix
    ./grafana
    ./adguard-home.nix
    #./tiddlywiki.nix
    #./paperless.nix
    # ./logseq.nix
    ./immich.nix
    ./incus.nix
    # TODO: hitting errors
    # ./cryptpad.nix
  ];
}
