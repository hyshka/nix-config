{pkgs, ...}: {
  environment.systemPackages = with pkgs; [docker-compose];

  # TODO split up
  virtualisation = {
    docker.enable = false;

    #oci-containers = {
    #        backend = "docker";
    #        containers = {
    #            homepage = {
    #                image = "ghcr.io/benphelps/homepage";
    #                autoStart = false; # TODO config below isn't working, docker container doesn't pick up files
    #                ports = [ "127.0.0.1:3001:3000" ];
    #                volumes = [
    #  	              "/etc/homepage:/app/config"
    # 			      "/var/run/docker.sock:/var/run/docker.sock:ro" # (optional) For docker integrations
    #                ];
    #                environment = {};
    #  	  };
    #        };
    #};
  };

  environment.etc = {
    "homepage/bookmarks.yaml" = {
      text = ''
        ---

      '';
    };
    "homepage/docker.yaml" = {
      text = ''
        ---

        my-docker:
          socket: /var/run/docker.sock
      '';
    };
    "homepage/widgets.yaml" = {
      text = ''
        ---

        - resources:
            cpu: true
            memory: true
            disk: /
      '';
    };
    "homepage/services.yaml" = {
      text = ''
        ---

        - Media:
            - Jellyfin:
                href: http://localhost:8096/
                icon: jellyfin
                server: my-docker
                container: jellyfin
            - Jellyseerr:
                href: http://localhost:5055/
                icon: jellyseerr
                server: my-docker
                container: jellyseerr
            - Radarr:
                href: http://localhost:7878/
                icon: radarr
                server: my-docker
                container: radarr
            - Sonarr:
                href: http://localhost:8989/
                icon: sonarr
                server: my-docker
                container: sonarr
            - Prowlarr:
                href: http://localhost:9696/
                icon: prowlarr
                server: my-docker
                container: prowlarr
            - Recyclarr:
                href: http://localhost/
                server: my-docker
                container: recyclarr
            - QBittorrent:
                href: http://localhost:8080/
                icon: qbittorrent
                server: my-docker
                container: qbittorrent
                  #widget:
                  #  type: qbittorrent
                  #  url: http://localhost:8080
                  #  username: admin
                  #  password: adminadmin
            - Wireguard:
                href: http://localhost/
                icon: mullvad
                server: my-docker
                container: wireguard

        - Backup:
            - Syncthing:
                href: http://localhost:8384/
            - Restic:
                href: http://localhost/
            - Backblaze:
                href: https://backblaze.com/
                icon: backblaze

        - Other:
            - Ntfy:
                href: http://localhost:8010/
                icon: ntfy
            - Psitransfer:
                href: http://localhost:3000/
            - Ddclient:
                href: http://localhost
            - Glances:
                href: http://localhost:61208/
                icon: glances
            - Namecheap:
                href: https://namecheap.com/
      '';
    };
  };
}
