{config, ...}: {
  services.adguardhome = {
    enable = true;
    host = "127.0.0.1";
    port = 3020;
    # TODO: use declarative config only
    mutableSettings = true;
    #allowDHCP = true;
    # https://github.com/AdguardTeam/AdGuardHome/wiki/Configuration#configuration-file
    settings = {
      http = "127.0.0.1:${toString config.services.adguardhome.port}";
      #dns = {
      #  bootstrap_dns = [
      #    "9.9.9.9"
      #    "8.8.8.8"
      #    "1.1.1.1"
      #  ];
      #};
    };
  };
}
