{
  services.samba = {
    enable = true;
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
      "ntfy-sh"
    ];
    extraConfig = ''
      server string = tiny1
      # restrict access to LAN and localhost
      hosts allow = 10.0.0. 127. 100.
      # limit connects to tailnet, lo always required
      bind interfaces only = yes
      interfaces = lo tailscale0
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
      storage = {
        path = "/mnt/storage";
        "read only" = "no";
        browseable = "yes";
        "guest ok" = "no";
        comment = "Primary Storage";
      };
    };
  };
}
