{config, ...}: {
  imports = [
    ./docker-compose.nix
  ];

  # docker interface for mediacenter network, allows docker to access ntfy
  # TODO: avoid hard-coding the interface
  # TODO: 8010 for ntfy
  networking.firewall.interfaces."br-0a93fdcc1a12".allowedTCPPorts = [
    config.services.calibre-server.port
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
    };
  };
}
