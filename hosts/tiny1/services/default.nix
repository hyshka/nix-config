{ pkgs, ... }:
{
  #imports = [
  #  ./ddclient
  #  ./docker
  #  ./glances
  #  ./home-assistant
  #  ./nginx
  #  ./ntfy
  #  ./openssh
  #  ./restic
  #  ./samba
  #  ./snapraid
  #  ./syncthing
  #];

  services.openssh = {
      enable = true;
      ports = [ 38000 ];
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
  };

  # TODO microbin
  # https://github.com/szabodanika/microbin

  systemd.services.glances = {
    serviceConfig = {
      User = "hyshka";
    };
    script = ''
      ${pkgs.glances}/bin/glances –enable-plugin smart --webserver --bind 127.0.0.1
    '';
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
  };
  environment.etc."glances/glances.conf" = {
    text = ''
      [global]
      check_update=False

      [network]
      hide=lo,wlan.*,docker.*

      [diskio]
      hide=loop.*

      [containers]
      disable=False

      [connections]
      disable=True

      [irq]
      disable=True
    '';
  };

  services.samba = {
    enable = true;
    # TODO open only for LAN?
    openFirewall = true;
    invalidUsers = [
      "root"
      # TODO abstract media server users
      "wireguard"
      "qbittorrent"
      "sonarr"
      "radarr"
      "jellyfin"
      "recyclarr"
      "jellyseer"
      "prowlarr"
    ];
    extraConfig = ''
      server string = tiny1
      # restrict access to LAN and localhost
      hosts allow = 10.0.0. 127.
      # limit connects to end0
      interfaces = 10.0.0.240/24
      # limit log size to 50kb
      max log size = 50
      # disable printer support
      printcap name = /dev/null
      load printers = no
    '';
    shares = {
      home = {
        path = "/home/hyshka";
        "read only" = "no";
        browseable = "yes";
        "guest ok" = "no";
        comment = "hyshka home folder";
      };
      #storage = {
      #  path = "/mnt/storage";
      #  "read only" = "no";
      #  browseable = "yes";
      #  "guest ok" = "no";
      #  comment = "Primary Storage";
      #};
    };
  };
}
