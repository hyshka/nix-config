{
  imports = [
    #./ddclient.nix
    ./docker.nix
    ./glances.nix
    ./home-assistant.nix
    ./homepage.nix
    ./media
    #./microbin.nix
    #./n8n.nix
    #./ntfy.nix
    ./restic.nix
    ./samba.nix
    ./snapraid.nix
    ./syncthing.nix
    ./silverbullet.nix
    ./caddy.nix
    ./acme.nix
    ./nextcloud.nix
    ./grafana.nix
    ./adguard-home.nix
    #./tiddlywiki.nix
    ./paperless.nix
    # ./logseq.nix
    ./immich.nix
    # TODO: hitting errors
    # ./cryptpad.nix
  ];
}
