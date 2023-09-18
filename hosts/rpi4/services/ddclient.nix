{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ ddclient ];

  sops.secrets = {
    ddclient_password = {};
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
}
