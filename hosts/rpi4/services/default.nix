{
  imports = [
    ./ddclient.nix
    ./docker.nix
    ./glances.nix
    ./home-assistant.nix
    ./nginx.nix
    ./ntfy.nix
    ./openssh.nix
    #./psitransfer.nix
    ./restic.nix
    ./samba.nix
    #./snapper.nix # TODO replaced by snapraid
    ./snapraid.nix
    ./syncthing.nix
  ];
}