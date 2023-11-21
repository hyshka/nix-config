{config, ...}: let
  # Ref: https://github.com/nikitawootten/infra/blob/main/hosts/hades/lab/homepage.nix
  settings = {
    title = "tiny1";
  };
  settingsFile = builtins.toFile "homepage-settings.yaml" (builtins.toJSON settings);
  bookmarks = [
    {
      Administration = [
        {
          Source = [
            {
              icon = "github";
              href = "https://github.com/hyshka/nix-config";
            }
          ];
        }
        {
          Cloudflare = [
            {
              icon = "cloudflare";
              href = "https://dash.cloudflare.com/";
            }
          ];
        }
      ];
    }
    {
      Development = [
        {
          "Nix Options Search" = [
            {
              abbr = "NS";
              href = "https://search.nixos.org/packages";
            }
          ];
        }
      ];
    }
  ];
  bookmarksFile = builtins.toFile "homepage-bookmarks.yaml" (builtins.toJSON bookmarks);

  widgets = [
    {
      resources = {
        cpu = true;
        memory = true;
        cputemp = true;
        uptime = true;
        label = "system";
        disk = "/";
      };
    }
    {
      search = {
        provider = "duckduckgo";
        target = "_blank";
      };
    }
  ];
  widgetsFile = builtins.toFile "homepage-widgets.yaml" (builtins.toJSON widgets);

  docker = {
    my-docker.socket = "/var/run/docker.sock";
  };
  dockerFile = builtins.toFile "homepage-docker.yaml" (builtins.toJSON docker);

  # TODO https://github.com/nikitawootten/infra/blob/main/hosts/hades/lab/homepage.nix#L77
  services = [
    {
      Backup = [
        {
          Syncthing = [
            {
              icon = "syncthing";
              href = "https://tbd.hyshka.com";
            }
          ];
        }
        {
          Restic = [
            {
              icon = "backblaze";
              href = "https://tbd.hyshka.com";
            }
          ];
        }
        {
          Backblaze = [
            {
              icon = "backblaze";
              href = "https://tbd.hyshka.com";
            }
          ];
        }
      ];
    }
    {
      Infrastructure = [
        {
          Ntfy = [
            {
              icon = "ntfy";
              href = "https://tbd.hyshka.com";
            }
          ];
        }
        {
          Ddclient = [
            {
              #icon = "ddclient";
              href = "https://tbd.hyshka.com";
            }
          ];
        }
        {
          Glances = [
            {
              icon = "glances";
              href = "https://tbd.hyshka.com";
            }
          ];
        }
        {
          Namecheap = [
            {
              #icon = "namecheap";
              href = "https://namecheap.com";
            }
          ];
        }
        {
          Mullvad = [
            {
              icon = "mullbad";
              href = "https://mullvad.net";
            }
          ];
        }
      ];
    }
    {
      Home = [
        {
          "Home Assistant" = [
            {
              icon = "home-assistant";
              href = "https://tbd.hyshka.com";
            }
          ];
        }
      ];
    }
    {
      Media = [
        {
          Jellyfin = [
            {
              icon = "jellyfin";
              href = "https://jellyfin.hyshka.com";
              description = "Jellyfin: Media server";
              server = "my-docker";
              container = "jellyfin";
              widget = {
                type = "jellyfin";
                url = "http://localhost:8096";
                key = "{{HOMEPAGE_VAR_JELLYFIN_APIKEY}}";
                enableBlocks = true;
                enableNowPlaying = true;
              };
            }
          ];
        }
        {
          Jellyseer = [
            {
              icon = "jellyseer";
              href = "https://jellyseer.hyshka.com";
              server = "my-docker";
              container = "jellyfin";
            }
          ];
        }
        {
          Radarr = [
            {
              icon = "radarr";
              href = "https://tbd.hyshka.com";
              server = "my-docker";
              container = "radarr";
            }
          ];
        }
        {
          Sonarr = [
            {
              icon = "sonarr";
              href = "https://tbd.hyshka.com";
              server = "my-docker";
              container = "sonarr";
            }
          ];
        }
        {
          Prowlarr = [
            {
              icon = "prowlarr";
              href = "https://tbd.hyshka.com";
              server = "my-docker";
              container = "prowlarr";
            }
          ];
        }
        {
          Recyclarr = [
            {
              #icon = "jellyseer";
              href = "https://tbd.hyshka.com";
              server = "my-docker";
              container = "recyclarr";
            }
          ];
        }
        {
          Qbittorrent = [
            {
              icon = "qbittorrent";
              href = "https://tbd.hyshka.com";
              server = "my-docker";
              container = "qbittorrent";
              #widget = {
              #  type = "qbittorrent";
              #  url = "https://tbd.hyshka.com";
              #  username = "todo";
              #  password = "todo";
              #};
            }
          ];
        }
        {
          Wireguard = [
            {
              icon = "wireguard";
              href = "https://tbd.hyshka.com";
              server = "my-docker";
              container = "wireguard";
            }
          ];
        }
      ];
    }
  ];
  servicesFile = builtins.toFile "homepage-services.yaml" (builtins.toJSON services);
in {
  virtualisation = {
    oci-containers = {
      containers.homepage = {
        image = "ghcr.io/benphelps/homepage";
        autoStart = true;
        ports = ["127.0.0.1:3001:3000"];
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock:ro"
          # TODO logs
          #"${config.lib.lab.mkConfigDir "homepage"}/logs/:/config/logs/"
          "${settingsFile}:/config/settings.yaml"
          "${servicesFile}:/config/services.yaml"
          "${bookmarksFile}:/config/bookmarks.yaml"
          "${widgetsFile}:/config/widgets.yaml"
          "${dockerFile}:/config/docker.yaml"
        ];
        environmentFiles = [config.sops.secrets.homepage.path];
      };
    };
  };

  sops.secrets = {
    homepage = {};
  };

  services.nginx.virtualHosts."dashboard.hyshka.com" = {
    forceSSL = true;
    enableACME = true;
    # auth file format: user:{PLAIN}password
    basicAuthFile = config.sops.secrets.nginx_basic_auth.path;
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:3001";
    };
  };
}
