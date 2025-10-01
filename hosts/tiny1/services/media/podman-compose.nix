# Auto-generated using compose2nix v0.3.2-pre.
{
  pkgs,
  lib,
  ...
}:
{
  # Runtime
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {
      # Required for container networking to be able to use names.
      dns_enabled = true;
    };
  };

  # Enable container name DNS for non-default Podman networks.
  # https://github.com/NixOS/nixpkgs/issues/226365
  networking.firewall.interfaces."podman+".allowedUDPPorts = [ 53 ];

  virtualisation.oci-containers.backend = "podman";

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
  systemd.services."podman-jellyfin" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-media_default.service"
    ];
    requires = [
      "podman-network-media_default.service"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
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
  systemd.services."podman-jellyseerr" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-media_default.service"
    ];
    requires = [
      "podman-network-media_default.service"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
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
  systemd.services."podman-prowlarr" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-media_default.service"
    ];
    requires = [
      "podman-network-media_default.service"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
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
  systemd.services."podman-qbittorrent" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
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
  systemd.services."podman-radarr" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-media_default.service"
    ];
    requires = [
      "podman-network-media_default.service"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
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
  systemd.services."podman-recyclarr" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "podman-network-media_default.service"
    ];
    requires = [
      "podman-network-media_default.service"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
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
  systemd.services."podman-sabnzbd" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
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
  systemd.services."podman-sonarr" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-media_default.service"
    ];
    requires = [
      "podman-network-media_default.service"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
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
  systemd.services."podman-wireguard" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-media_default.service"
    ];
    requires = [
      "podman-network-media_default.service"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-media_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f media_default";
    };
    script = ''
      podman network inspect media_default || podman network create media_default
    '';
    partOf = [ "podman-compose-media-root.target" ];
    wantedBy = [ "podman-compose-media-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-media-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
