{ config, pkgs, ... }:
{
  services.snapper = {
      configs = {
              storage = {
                  SUBVOLUME = "/mnt/storage";
		  TIMELINE_CREATE = true;
		  TIMELINE_CLEANUP = true;
                  TIMELINE_LIMIT_HOURLY = 12;
                  TIMELINE_LIMIT_DAILY = 7;
                  TIMELINE_LIMIT_WEEKLY = 4;
                  TIMELINE_LIMIT_MONTHLY = 3;
                  TIMELINE_LIMIT_YEARLY = 0;
                };
      };
  };

  services.openssh = {
      enable = true;
      ports = [ 38000 ];
      settings = {
        passwordAuthentication = false;
        permitRootLogin = "no";
      };
  };

  services.ddclient = {
      enable = true;
      protocol = "namecheap";
      username = "hyshka.com";
      domains = [ "psitransfer" "jellyseerr" "jellyfin" "ntfy" "dashy" "glances"];
      use = "web, web=dynamicdns.park-your-domain.com/getip";
      server = "dynamicdns.park-your-domain.com";
      # TODO move to sops
      passwordFile = "/var/ddclient-adminpass";
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
      devices = {
              "starship" = { id = "H2KQXW6-KBPZXXF-TDAWBJW-GZHGWEH-ZSLT7IN-N7CN2UB-TFY6KEH-CYLSXAC"; };
              "galaxys9" = { id = "RGNDH6P-UWJZ464-NSXPOQ6-SJE3V6S-GO6KDYC-3RI5NL4-HBWW25V-JVRS2AZ"; };
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
              "Phone Camera" = {
                      id = "sm-g930f_pwyw-photos";
                      path = "/mnt/storage/hyshka/phone-camera";
                      devices = [ "galaxys9" ];
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
    };
  };

  # TODO replace with microbin
  # https://github.com/szabodanika/microbin
  services.psitransfer = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = 3000;
      uploadDirectory = "/mnt/psitransfer";
      # TODO move to sops
      uploadPasswordFile = "/var/psitransfer-uploadpass";
  };

  virtualisation = {
      docker.enable = true;
      oci-containers = {
              backend = "docker";
              containers.dashy = {
                      image = "lissy93/dashy";
                      autoStart = true;
                      ports = [ "127.0.0.1:8888:80" ];
                      volumes = [
                              "/home/hyshka/dashy-conf.yml:/app/public/conf.yml"
                      ];
                      environment = {};
              };
      };
  };

  systemd.services.glances = {
    serviceConfig = {
      User = "hyshka";
    };
    script = ''
      ${pkgs.glances}/bin/glances --webserver --bind 127.0.0.1
    '';
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
  };

  sops.secrets.nginx_basic_auth = {
    sopsFile = ../secrets.yaml;
  };
}
