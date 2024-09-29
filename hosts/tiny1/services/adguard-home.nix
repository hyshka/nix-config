{
  services.adguardhome = {
    enable = true;
    #host = "127.0.0.1"; # TODO: limit to localhost
    port = 3020;
    # https://github.com/AdguardTeam/AdGuardHome/wiki/Configuration#configuration-file
    # settings = {}; # TODO: configure settings through module
  };
}
