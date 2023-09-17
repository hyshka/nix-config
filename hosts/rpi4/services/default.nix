{ config, pkgs, ... }:
{
  sops.secrets = {
    sops.secrets.ddclient_password = {};
    sops.secrets.psitransfer_password = {};
    restic_password = {
      owner = config.users.users.hyshka.name;
      group = config.users.users.hyshka.group;
    };
    restic_environmentFile = {
      owner = config.users.users.hyshka.name;
      group = config.users.users.hyshka.group;
    };
    sops.secrets.nginx_basic_auth = {
      owner = config.services.nginx.user;
      group = config.services.nginx.group;
    };
  };

  snapraid = {
    enable = true;
    parityFiles = [
      "/mnt/parity1/snapraid.parity"
    ];
    contentFiles = [
      "/var/snapraid.content"
      "/mnt/disk1/.snapraid.content"
      "/mnt/disk2/.snapraid.content"
    ];
    dataDisks = {
      d1 = "/mnt/disk1/";
      d2 = "/mnt/disk2/";
    };
    exclude = [
      # https://github.com/IronicBadger/infra/blob/master/group_vars/morpheus.yaml#L52
      "*.unrecoverable"
      "/tmp/"
      "/lost+found/"
      "downloads/"
      "appdata/"
      "*.!sync"
      ".AppleDouble"
      "._AppleDouble"
      ".DS_Store"
      "._.DS_Store"
      ".Thumbs.db"
      ".fseventsd"
      ".Spotlight-V100"
      ".TemporaryItems"
      ".Trashes"
      ".Trash-*"
      ".AppleDB"
      ".nfo"
    ];
    #sync.interval = "01:00"; # defaults to daily at 1 am
    scrub = {
      # TODO these PMS values may be out-of-date, snapraid recommends scrub once/week
      #plan = 22; # 22%
      #olderThan = 8;
      # interval = "Mon *-*-* 02:00:00"; # defaults to every Monday at 2 am
    };
    # TODO healthcheck notification for sync & scrub
  };

  #services.snapper = {
  #    configs = {
  #            storage = {
  #                # TODO should this go through mergerfs?
  #                SUBVOLUME = "/mnt/disk1/hyshka";
  #      	  TIMELINE_CREATE = true;
  #      	  TIMELINE_CLEANUP = true;
  #                TIMELINE_LIMIT_HOURLY = 12;
  #                TIMELINE_LIMIT_DAILY = 7;
  #                TIMELINE_LIMIT_WEEKLY = 4;
  #                TIMELINE_LIMIT_MONTHLY = 3;
  #                TIMELINE_LIMIT_YEARLY = 0;
  #              };
  #    };
  #};

  services.restic.backups.hyshka = {
    user = "hyshka";
    passwordFile = config.sops.secrets.restic_password.path;
    environmentFile = config.sops.secrets.restic_environmentFile.path;
    initialize = true;
    paths = [
      "/mnt/storage/hyshka"
    ];
    exclude = [
      ".snapshots"
      ".Trash-1000"
    ];
    repository = "s3:s3.us-west-000.backblazeb2.com/storage-hyshka";
    timerConfig = {
      OnCalendar = "03:00";
      Persistent = true;
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

  services.ddclient = {
      enable = true;
      protocol = "namecheap";
      username = "hyshka.com";
      domains = [ "psitransfer" "jellyseerr" "jellyfin" "ntfy" "dashy" "glances" "dashboard" ];
      use = "web, web=dynamicdns.park-your-domain.com/getip";
      server = "dynamicdns.park-your-domain.com";
      passwordFile = config.sops.secrets.ddclient_password.path;
  };

  services.ntfy-sh = {
      enable = true;
      settings = {
      	base-url = "https://ntfy.hyshka.com";
      	listen-http = "0.0.0.0:8010";
      	behind-proxy = true;
      	auth-default-access = "deny-all";
      	# requires:
      	# sudo mkdir /var/lib/ntfy-sh/
      	# sudo touch /var/lib/ntfy-sh/user.db
      	# sudo chown ntfy-sh:ntfy-sh /var/lib/ntfy-sh/user.db
      	# sudo chmod 600 /var/lib/ntfy-sh/user.db
      	# ntfy user add --role=admin hyshka
      	auth-file = "/var/lib/ntfy-sh/user.db";
      	#log-level = "DEBUG";
      };
  };

  services.syncthing = {
      enable = true;
      dataDir = "/home/hyshka";
      configDir = "/home/hyshka/.config/syncthing";
      user = "hyshka";
      group = "users";
      overrideDevices = true;
      overrideFolders = true;
      key = "/home/hyshka/syncthing-key.pem";
      cert = "/home/hyshka/syncthing-cert.pem";
      extraOptions = {
        defaults = {
	  folder = {
	    path = "/mnt/storage/hyshka/";
	    type = "receiveonly";
	  };
	};
      };
      devices = {
              "starship" = { id = "H2KQXW6-KBPZXXF-TDAWBJW-GZHGWEH-ZSLT7IN-N7CN2UB-TFY6KEH-CYLSXAC"; };
              "renee-galaxys9" = { id = "F6EBD2Q-TSSEF3J-YR4JH7L-ZHM6BQE-O7YOLSY-XKVHCSW-JUNM66E-YHDFWQK"; };
              "bryan-pixel4" = { id = "IUO5O7L-5CKMEZQ-4USKX7X-JTFZHZZ-3V6CBZE-4PQHMEU-TZXE7YN-FEDYMA2"; };
	      # TODO Bryan's old S9?
              "galaxys9" = { id = "RGNDH6P-UWJZ464-NSXPOQ6-SJE3V6S-GO6KDYC-3RI5NL4-HBWW25V-JVRS2AZ"; };
	      # TODO why was this in the old config?
              #"rpi4-nixos" = { id = "SBU2DEZ-MEVLQ2S-2HN6L6N-3VILABR-Z3C5NWU-UD36AF7-4HVFWZ7-W2QJWQB"; };
      };
      folders = {
              "Darktable" = {
                      id = "4harq-seslg";
                      path = "/mnt/storage/hyshka/Darktable";
                      devices = [ "starship" ];
                      type = "receiveonly";
              };
              "Music" = {
                      id = "ijjkj-sfe6a";
                      path = "/mnt/storage/hyshka/Music";
                      devices = [ "starship" ];
                      type = "receiveonly";
              };
              "Pictures" = {
                      id = "nnvzz-njc6m";
                      path = "/mnt/storage/hyshka/Pictures";
                      devices = [ "starship" ];
                      type = "receiveonly";
              };
              "Documents" = {
                      id = "vzqdy-afqjw";
                      path = "/mnt/storage/hyshka/Documents";
                      devices = [ "starship" ];
                      type = "receiveonly";
              };
              "Videos" = {
                      id = "xjkcs-vzunq";
                      path = "/mnt/storage/hyshka/Videos";
                      devices = [ "starship" ];
                      type = "receiveonly";
              };
              "Finance" = {
                      id = "4rqlm-lmagt";
                      path = "/mnt/storage/hyshka/Finance";
                      devices = [ "starship" ];
                      type = "receiveonly";
              };
              "Work" = {
                      id = "dwgeq-drahv";
                      path = "/mnt/storage/hyshka/work";
                      devices = [ "starship" ];
                      type = "receiveonly";
              };
              "Home Notes" = {
                      id = "ljd5z-m6qfp";
                      path = "/mnt/storage/hyshka/Home Notes";
                      devices = [ "starship" "renee-galaxys9" "bryan-pixel4" ];
                      type = "receiveonly";
              };
              "Phone Camera" = {
                      id = "sm-g930f_pwyw-photos";
                      path = "/mnt/storage/hyshka/phone-camera";
                      devices = [ "galaxys9" ];
                      type = "receiveonly";
              };
              "Phone Pictures" = {
                      id = "ti8iw-ywmhx";
                      path = "/mnt/storage/hyshka/Phone Pictures";
                      devices = [ "bryan-pixel4" ];
                      type = "receiveonly";
              };
      };
  };

  services.nginx = {
     enable = true;
     recommendedGzipSettings = true;
     recommendedOptimisation = true;
     recommendedTlsSettings = true;

     virtualHosts = {
      "psitransfer.hyshka.com" = {
         forceSSL = true;
         enableACME = true;
         locations."/" = {
           recommendedProxySettings = true;
           proxyPass = "http://127.0.0.1:3000";
           extraConfig = ''
             proxy_buffering off;
             proxy_request_buffering off;
             client_max_body_size 3g;
           '';
        };
        extraConfig = ''
           add_header Content-Security-Policy "frame-ancestors 'none'";
           add_header X-Frame-Options "DENY";
        '';
      };
      "jellyseerr.hyshka.com" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://127.0.0.1:5055";
        };
      };
      "jellyfin.hyshka.com" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://127.0.0.1:8096";
        };
      };
      "ntfy.hyshka.com" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://127.0.0.1:8010";
          proxyWebsockets = true;
        };
      };
      "dashy.hyshka.com" = {
        forceSSL = true;
        enableACME = true;
	# auth file format: user:{PLAIN}password
        basicAuthFile = config.sops.secrets.nginx_basic_auth.path;
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://127.0.0.1:8888";
        };
      };
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

  # TODO replace with microbin
  # https://github.com/szabodanika/microbin
  services.psitransfer = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = 3000;
      uploadDirectory = "/mnt/storage/psitransfer";
      uploadPasswordFile = config.sops.secrets.psitransfer_password.path;
  };

  virtualisation = {
      docker.enable = true;
      oci-containers = {
              backend = "docker";
              containers = {
	          dashy = {
                      image = "lissy93/dashy";
                      autoStart = false;
                      ports = [ "127.0.0.1:8888:80" ];
                      volumes = [
                              "/home/hyshka/dashy-conf.yml:/app/public/conf.yml"
                      ];
                      environment = {};
		  };
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
      server string = rpi4
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
      storage = {
        path = "/mnt/storage";
        "read only" = "no";
        browseable = "yes";
        "guest ok" = "no";
        comment = "Primary Storage";
      };
    };
  };

  services.home-assistant = {
    enable = true;
    openFirewall = true;
    extraComponents = [
      # defaults
      "default_config"
      # Components required to complete the onboarding
      "met"
      "esphome"
      "radio_browser"
      # extras
      "environment_canada"
    ];
  };

}
