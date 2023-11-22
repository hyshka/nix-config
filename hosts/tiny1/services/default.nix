{pkgs, ...}: {
  imports = [
    ./ddclient.nix
    ./docker.nix
    ./glances.nix
    ./home-assistant.nix
    ./homepage.nix
    ./media.nix
    ./n8n.nix
    ./nginx.nix
    ./ntfy.nix
    ./openssh.nix
    ./restic.nix
    ./samba.nix
    ./snapraid.nix
    ./syncthing.nix
  ];

  # TODO microbin
  # https://github.com/szabodanika/microbin
}
