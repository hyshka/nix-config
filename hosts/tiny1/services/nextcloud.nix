{
  config,
  pkgs,
  lib,
  ...
}: {
  sops.secrets = {
    nextcloud-adminPass = {
      owner = "nextcloud";
      group = "nextcloud";
    };
  };

  # The Caddy rules for Nextcloud were too complex. Reverse proxy the
  # buit-in Nginx configuration instead.
  services.nginx.virtualHosts."localhost".listen = [
    {
      addr = "127.0.0.1";
      port = 8082;
    }
  ];

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud29;
    home = "/mnt/storage/nextcloud";
    https = true;
    autoUpdateApps.enable = true;
    hostName = "localhost";

    # Fix Nextcloud warning
    phpOptions."opcache.interned_strings_buffer" = "16";

    settings = {
      trusted_proxies = ["127.0.0.1"];
      trusted_domains = ["cloud.home.hyshka.com"];
      default_phone_region = "CA";
      maintenance_window_start = "4";
      preview_ffmpeg_path = lib.getExe pkgs.ffmpeg;
      "memories.exiftool" = lib.getExe pkgs.exiftool;
      "memories.ffmpeg_path" = lib.getExe' pkgs.ffmpeg "ffmpeg";
      "memories.ffprobe_path" = lib.getExe' pkgs.ffmpeg "ffprobe";
      "memories.vod.ffmpeg" = lib.getExe' pkgs.ffmpeg "ffmpeg";
      "memories.vod.ffprobe" = lib.getExe' pkgs.ffmpeg "ffprobe";
      # TODO vaapi https://github.com/NuschtOS/nixos-modules/blob/fb562371c3773fc1554cf450c93db35c377f4b3b/modules/nextcloud.nix#L15
      recognize = {
        nice_binary = lib.getExe' pkgs.coreutils "nice";
      };
      enabledPreviewProviders = [
        "OC\\Preview\\AVI"
        "OC\\Preview\\BMP"
        "OC\\Preview\\GIF"
        "OC\\Preview\\HEIC"
        "OC\\Preview\\JPEG"
        "OC\\Preview\\Krita"
        "OC\\Preview\\MarkDown"
        "OC\\Preview\\MKV"
        "OC\\Preview\\Movie"
        "OC\\Preview\\MP3"
        "OC\\Preview\\MP4"
        "OC\\Preview\\OpenDocument"
        "OC\\Preview\\PDF"
        "OC\\Preview\\PNG"
        "OC\\Preview\\TXT"
        "OC\\Preview\\XBitmap"
      ];
    };

    config = {
      adminuser = "admin";
      adminpassFile = config.sops.secrets.nextcloud-adminPass.path;
    };

    # extraApps examples
    # - https://github.com/dverdonschot/nixos-systems-configuration/blob/1f7e7c7861d0243b8145baa2535a02a04efd83e5/nix-containers/nextcloud-container.nix#L84
    # - https://github.com/nmasur/dotfiles/blob/4883532c65383c2615047bd1bb3ed5cf606f996e/modules/nixos/services/nextcloud.nix#L33

    # Nextcloud Memories (+Preview Generator, +Recognize)
    # TODO Add a (system) cron job for ./occ preview:pre-generate
    # Reverse Geocoding not supported with SQLite

    # Nextcloud Office
    # TODO https://wiki.nixos.org/wiki/Nextcloud#Plugins
  };

  # For Recognize
  users.users.nextcloud = {
    # binaries located in /etc/profiles/per-user/nextcloud/bin/
    packages = [pkgs.nodejs pkgs.libtensorflow];
  };
}
