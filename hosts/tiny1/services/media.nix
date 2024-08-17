{
  # docker interface for mediacenter network, allows docker to access ntfy
  networking.firewall.interfaces."br-65ee147cd7f3".allowedTCPPorts = [8010];

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
