{config, pkgs, ...}: {
  sops.secrets = {
    nextcloud-adminPass = {
      owner = "nextcloud";
      group = "nextcloud";
    };
  };

  # The Caddy rules for Nextcloud were too complex. Reverse proxy the
  # buit-in Nginx configuration instead.
  services.nginx.virtualHosts."localhost".listen = [ { addr = "127.0.0.1"; port = 8082; } ];

  # Configure Nextcloud
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
      trusted_domains = [ "cloud.home.hyshka.com" ];
      default_phone_region = "CA";
      maintenance_window_start = "4";
    };

    config = {
      adminuser = "admin";
      adminpassFile = config.sops.secrets.nextcloud-adminPass.path;
    };

    # extraApps examples
    # - https://github.com/dverdonschot/nixos-systems-configuration/blob/1f7e7c7861d0243b8145baa2535a02a04efd83e5/nix-containers/nextcloud-container.nix#L84
    # - https://github.com/nmasur/dotfiles/blob/4883532c65383c2615047bd1bb3ed5cf606f996e/modules/nixos/services/nextcloud.nix#L33
  };
}
