# Auto-generated using compose2nix v0.3.2-pre.
{
  pkgs,
  lib,
  ...
}: {
  # Runtime
  #virtualisation.docker = {
  #  enable = true;
  #  autoPrune.enable = true;
  #};
  #virtualisation.oci-containers.backend = "docker";

  # Containers
  virtualisation.oci-containers.containers."jellyfin" = {
    image = "lscr.io/linuxserver/jellyfin:latest";
    environment = {
      "PGID" = "13000";
      "PUID" = "13006";
      "TZ" = "America/Edmonton";
      "UMASK" = "002";
    };
    volumes = [
      "/home/hyshka/media/jellyfin-config:/config:rw"
      "/mnt/storage/mediacenter/media:/data:rw"
    ];
    ports = [
      "8096:8096/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--add-host=host.docker.internal:host-gateway"
      "--device=/dev/dri:/dev/dri:rwm"
      "--network-alias=jellyfin"
      "--network=media_default"
    ];
  };
  systemd.services."docker-jellyfin" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-media_default.service"
    ];
    requires = [
      "docker-network-media_default.service"
    ];
    partOf = [
      "docker-compose-media-root.target"
    ];
    wantedBy = [
      "docker-compose-media-root.target"
    ];
  };

  virtualisation.oci-containers.containers."jellyseerr" = {
    image = "fallenbagel/jellyseerr:latest";
    environment = {
      "TZ" = "America/Edmonton";
    };
    volumes = [
      "/home/hyshka/media/jellyseer-config:/app/config:rw"
    ];
    ports = [
      "5055:5055/tcp"
    ];
    user = "13008:13000";
    log-driver = "journald";
    extraOptions = [
      "--add-host=host.docker.internal:host-gateway"
      "--network-alias=jellyseerr"
      "--network=media_default"
    ];
  };
  systemd.services."docker-jellyseerr" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-media_default.service"
    ];
    requires = [
      "docker-network-media_default.service"
    ];
    partOf = [
      "docker-compose-media-root.target"
    ];
    wantedBy = [
      "docker-compose-media-root.target"
    ];
  };

  virtualisation.oci-containers.containers."prowlarr" = {
    image = "lscr.io/linuxserver/prowlarr:develop";
    environment = {
      "PGID" = "13000";
      "PUID" = "13009";
      "TZ" = "America/Edmonton";
      "UMASK" = "002";
    };
    volumes = [
      "/home/hyshka/media/prowlarr-config:/config:rw"
    ];
    ports = [
      "9696:9696/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=prowlarr"
      "--network=media_default"
    ];
  };
  systemd.services."docker-prowlarr" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-media_default.service"
    ];
    requires = [
      "docker-network-media_default.service"
    ];
    partOf = [
      "docker-compose-media-root.target"
    ];
    wantedBy = [
      "docker-compose-media-root.target"
    ];
  };

  virtualisation.oci-containers.containers."qbittorrent" = {
    image = "lscr.io/linuxserver/qbittorrent:latest";
    environment = {
      "PGID" = "13000";
      "PUID" = "13002";
      "TZ" = "America/Edmonton";
      "UMASK" = "002";
      "WEBUI_PORT" = "8080";
    };
    volumes = [
      "/home/hyshka/media/qbittorrent-config:/config:rw"
      "/mnt/storage/mediacenter/torrents:/data/torrents:rw"
    ];
    dependsOn = [
      "wireguard"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network=container:wireguard"
    ];
  };
  systemd.services."docker-qbittorrent" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    partOf = [
      "docker-compose-media-root.target"
    ];
    wantedBy = [
      "docker-compose-media-root.target"
    ];
  };

  virtualisation.oci-containers.containers."radarr" = {
    image = "lscr.io/linuxserver/radarr:latest";
    environment = {
      "PGID" = "13000";
      "PUID" = "13004";
      "TZ" = "America/Edmonton";
      "UMASK" = "002";
    };
    volumes = [
      "/home/hyshka/media/radarr-config:/config:rw"
      "/mnt/storage/mediacenter:/data:rw"
    ];
    ports = [
      "7878:7878/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=radarr"
      "--network=media_default"
    ];
  };
  systemd.services."docker-radarr" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-media_default.service"
    ];
    requires = [
      "docker-network-media_default.service"
    ];
    partOf = [
      "docker-compose-media-root.target"
    ];
    wantedBy = [
      "docker-compose-media-root.target"
    ];
  };

  systemd.tmpfiles.settings."readarr" = {
    "/home/hyshka/media/readarr-config" = {
      d = {
        group = "mediacenter";
        mode = "0755";
        user = "readarr";
      };
    };
    "/mnt/storage/mediacenter/media/books" = {
      d = {
        group = "mediacenter";
        mode = "0755";
        user = "hyshka";
      };
    };
  };
  virtualisation.oci-containers.containers."readarr" = {
    image = "lscr.io/linuxserver/readarr:develop";
    environment = {
      "PGID" = "13000";
      "PUID" = "13005";
      "TZ" = "America/Edmonton";
      "UMASK" = "002";
    };
    volumes = [
      "/home/hyshka/media/readarr-config:/config:rw"
      "/mnt/storage/mediacenter:/data:rw"
    ];
    ports = [
      "8787:8787/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=readarr"
      "--network=media_default"
    ];
  };
  systemd.services."docker-readarr" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-media_default.service"
    ];
    requires = [
      "docker-network-media_default.service"
    ];
    partOf = [
      "docker-compose-media-root.target"
    ];
    wantedBy = [
      "docker-compose-media-root.target"
    ];
  };

  virtualisation.oci-containers.containers."recyclarr" = {
    image = "ghcr.io/recyclarr/recyclarr";
    environment = {
      "TZ" = "America/Edmonton";
    };
    volumes = [
      "/home/hyshka/media/recyclarr-config:/config:rw"
    ];
    user = "13007:13000";
    log-driver = "journald";
    extraOptions = [
      "--network-alias=recyclarr"
      "--network=media_default"
    ];
  };
  systemd.services."docker-recyclarr" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "docker-network-media_default.service"
    ];
    requires = [
      "docker-network-media_default.service"
    ];
    partOf = [
      "docker-compose-media-root.target"
    ];
    wantedBy = [
      "docker-compose-media-root.target"
    ];
  };

  virtualisation.oci-containers.containers."sabnzbd" = {
    image = "lscr.io/linuxserver/sabnzbd:latest";
    environment = {
      "PGID" = "13000";
      "PUID" = "13010";
      "TZ" = "America/Edmonton";
      "UMASK" = "002";
    };
    volumes = [
      "/home/hyshka/media/sabnzbd-config:/config:rw"
      "/mnt/storage/mediacenter/usenet:/data/usenet:rw"
    ];
    dependsOn = [
      "wireguard"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network=container:wireguard"
    ];
  };
  systemd.services."docker-sabnzbd" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    partOf = [
      "docker-compose-media-root.target"
    ];
    wantedBy = [
      "docker-compose-media-root.target"
    ];
  };

  virtualisation.oci-containers.containers."sonarr" = {
    image = "lscr.io/linuxserver/sonarr:latest";
    environment = {
      "PGID" = "13000";
      "PUID" = "13003";
      "TZ" = "America/Edmonton";
      "UMASK" = "002";
    };
    volumes = [
      "/home/hyshka/media/sonarr-config:/config:rw"
      "/mnt/storage/mediacenter:/data:rw"
    ];
    ports = [
      "8989:8989/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=sonarr"
      "--network=media_default"
    ];
  };
  systemd.services."docker-sonarr" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-media_default.service"
    ];
    requires = [
      "docker-network-media_default.service"
    ];
    partOf = [
      "docker-compose-media-root.target"
    ];
    wantedBy = [
      "docker-compose-media-root.target"
    ];
  };

  virtualisation.oci-containers.containers."wireguard" = {
    image = "lscr.io/linuxserver/wireguard:latest";
    environment = {
      "PGID" = "13000";
      "PUID" = "13001";
      "TZ" = "America/Edmonton";
      "UMASK" = "002";
    };
    volumes = [
      "/home/hyshka/media/wireguard-config:/config:rw"
    ];
    ports = [
      "8080:8080/tcp"
      "8085:8085/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--cap-add=SYS_MODULE"
      "--dns=194.242.2.2"
      "--network-alias=wireguard"
      "--network=media_default"
      "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
    ];
  };
  systemd.services."docker-wireguard" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-media_default.service"
    ];
    requires = [
      "docker-network-media_default.service"
    ];
    partOf = [
      "docker-compose-media-root.target"
    ];
    wantedBy = [
      "docker-compose-media-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-media_default" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f media_default";
    };
    script = ''
      docker network inspect media_default || docker network create media_default
    '';
    partOf = ["docker-compose-media-root.target"];
    wantedBy = ["docker-compose-media-root.target"];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-media-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };
}