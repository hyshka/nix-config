{
  services.samba = {
    enable = true;
    settings = {
      global = {
        "server string" = "tiny1";
        # restrict access to LAN, localhost, and tailnet
        "hosts allow" = ["10.0.0." "127." "100."];
        # limit connects to LAN and tailnet, lo always required
        "bind interfaces only" = "yes";
        "interfaces" = ["lo" "enp0s31f6" "tailscale0"];
        # limit log size to 50kb
        "max log size" = 50;
        # disable printer support
        "printcap name" = "/dev/null";
        "load printers" = "no";
        "invalid users" = [
          "root"
          # TODO abstract media server users
          "wireguard"
          "qbittorrent"
          "sonarr"
          "radarr"
          "readarr"
          "jellyfin"
          "recyclarr"
          "jellyseer"
          "prowlarr"
          "sabnzbd"
          "ntfy-sh"
        ];
      };
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
      # TODO: timemachine share
      # https://blog.jhnr.ch/2023/01/09/setup-apple-time-machine-network-drive-with-samba-on-ubuntu-22.04/
    };
  };
}
