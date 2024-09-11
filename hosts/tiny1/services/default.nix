{
  imports = [
    ../../common/tailscale.nix
    #./ddclient.nix
    ./docker.nix
    ./glances.nix
    ./home-assistant.nix
    ./homepage.nix
    ./media.nix
    #./microbin.nix
    #./n8n.nix
    #./ntfy.nix
    ./openssh.nix
    ./restic.nix
    ./samba.nix
    ./snapraid.nix
    ./syncthing.nix
    ./silverbullet.nix
    ./caddy.nix
    ./acme.nix
    #./tiddlywiki.nix
    # TODO logseq https://github.com/NixOS/nixpkgs/pull/273532
  ];
}
