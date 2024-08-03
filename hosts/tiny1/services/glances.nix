{pkgs, ...}: {
  environment.systemPackages = with pkgs; [glances python310Packages.psutil hddtemp];

  systemd.services.glances = {
    serviceConfig = {
      User = "hyshka";
    };
    script = ''
      ${pkgs.glances}/bin/glances --enable-plugin smart --webserver --bind 127.0.0.1 --bind 100.116.243.20
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

  # TODO custom tailscale domain

  #services.caddy.virtualHosts."glances.home.hyshka.com" = {
  #  #useACMEHost = "*.home.hyshka";
  #  extraConfig = ''
  #    reverse_proxy :61208
  #    tls {
  #      get_certificate tailscale
  #    }
  #  '';
  #};
}
