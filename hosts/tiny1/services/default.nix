{ config, pkgs, ... }:
{
  sops.secrets = {
    restic_password = {
      sopsFile = ../secrets.yaml;
      owner = config.users.users.hyshka.name;
      group = config.users.users.hyshka.group;
    };
    restic_environmentFile = {
      sopsFile = ../secrets.yaml;
      owner = config.users.users.hyshka.name;
      group = config.users.users.hyshka.group;
    };
    nginx_basic_auth = {
      sopsFile = ../secrets.yaml;
      owner = config.services.nginx.user;
      group = config.services.nginx.group;
    };
  };

  services.openssh = {
      enable = true;
      ports = [ 38000 ];
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
  };

  services.nginx = {
     enable = true;
     recommendedGzipSettings = true;
     recommendedOptimisation = true;
     recommendedTlsSettings = true;

     virtualHosts = {
      "glances.hyshka.com" = {
        forceSSL = true;
        enableACME = true;
        basicAuthFile = config.sops.secrets.nginx_basic_auth.path;
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://127.0.0.1:61208";
        };
      };
      "dashboard.hyshka.com" = {
        forceSSL = true;
        enableACME = true;
        # auth file format: user:{PLAIN}password
        basicAuthFile = config.sops.secrets.nginx_basic_auth.path;
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://127.0.0.1:3001";
        };
      };
    };
  };

  # TODO microbin
  # https://github.com/szabodanika/microbin

  virtualisation = {
      docker.enable = true;
      oci-containers = {
              backend = "docker";
              containers = {
                  homepage = {
                      image = "ghcr.io/benphelps/homepage";
                      autoStart = true;
                      ports = [ "127.0.0.1:3001:3000" ];
                      volumes = [
        	              # TODO write config with nix
        	              "/home/hyshka/homepage-conf:/app/config"
       			      "/var/run/docker.sock:/var/run/docker.sock" # (optional) For docker integrations
                      ];
                      environment = {};
        	  };
              };
      };
  };

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
      interfaces = 10.0.0.250/24
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
