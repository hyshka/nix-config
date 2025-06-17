{config, ...}: {
  imports = [
    ./docker-compose.nix
  ];

  # Allow containers to access services running on the host
  # TODO: avoid hard-coding the Docker interface
  networking.firewall.interfaces."docker0".allowedTCPPorts = [
    config.services.calibre-server.port
    2586 # ntfy
  ];

  users = {
    groups = {
      mediacenter = {
        gid = 13000;
      };
    };
    users = {
      wireguard = {
        isSystemUser = true;
        uid = 13001;
        group = "mediacenter";
      };
      qbittorrent = {
        isSystemUser = true;
        uid = 13002;
        group = "mediacenter";
      };
      sonarr = {
        isSystemUser = true;
        uid = 13003;
        group = "mediacenter";
      };
      radarr = {
        isSystemUser = true;
        uid = 13004;
        group = "mediacenter";
      };
      readarr = {
        isSystemUser = true;
        uid = 13005;
        group = "mediacenter";
      };
      jellyfin = {
        isSystemUser = true;
        uid = 13006;
        group = "mediacenter";
        # Unsure if video is required for hardware accel
        extraGroups = ["video" "render"];
      };
      recyclarr = {
        isSystemUser = true;
        uid = 13007;
        group = "mediacenter";
      };
      jellyseer = {
        isSystemUser = true;
        uid = 13008;
        group = "mediacenter";
      };
      prowlarr = {
        isSystemUser = true;
        uid = 13009;
        group = "mediacenter";
      };
      sabnzbd = {
        isSystemUser = true;
        uid = 13010;
        group = "mediacenter";
      };
      ebookbuddy = {
        isSystemUser = true;
        uid = 13011;
        group = "mediacenter";
      };
      pinchflat = {
        isSystemUser = true;
        uid = 13012;
        group = "mediacenter";
      };
    };
  };
}
