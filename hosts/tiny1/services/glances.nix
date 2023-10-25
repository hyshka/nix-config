{
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = with pkgs; [glances python310Packages.psutil hddtemp];

  systemd.services.glances = {
    serviceConfig = {
      User = "hyshka";
    };
    script = ''
      ${pkgs.glances}/bin/glances --enable-plugin smart --webserver --bind 127.0.0.1
    '';
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
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

  services.nginx.virtualHosts."glances.hyshka.com" = {
    forceSSL = true;
    enableACME = true;
    basicAuthFile = config.sops.secrets.nginx_basic_auth.path;
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:61208";
    };
  };
}
