{
  config,
  lib,
  pkgs,
  ...
}: let
  adguardUser = "adguardhome";
in {
  # This will conflict with Incus if we bind to all interfaces
  networking.firewall.interfaces.enp0s31f6.allowedUDPPorts = [53];
  networking.firewall.interfaces.tailscale0.allowedUDPPorts = [53];

  services.adguardhome = {
    enable = true;
    host = "127.0.0.1";
    port = 3020;
    # TODO: use declarative config only
    mutableSettings = true;
    #allowDHCP = true;
    # https://github.com/AdguardTeam/AdGuardHome/wiki/Configuration#configuration-file
    # https://github.com/luisholanda/dotfiles/blob/e61b7bc0c819df2cb940ac5240795f05d251edc0/modules/services/networking/dns.nix#L8
    settings = {
      http = "127.0.0.1:${toString config.services.adguardhome.port}";
      users = [
        {
          name = "admin";
          password = "ADGUARDPASS"; # placeholder
        }
      ];
      auth_attempts = 3;
      block_auth_min = 3600;
      dns = {
        # This will conflict with Incus if we bind to all interfaces
        bind_hosts = [
          "127.0.0.1"
          "::1"
          "100.116.243.20" # tailscale0
        ];
        #  bootstrap_dns = [
        #    "9.9.9.9"
        #    "8.8.8.8"
        #    "1.1.1.1"
        #  ];
      };
    };
  };

  sops.secrets.adguard-passwordFile = {
    owner = adguardUser;
    group = adguardUser;
  };

  # https://github.com/truxnell/nix-config/blob/675e682e2280da830a9268c9a7822f31936b789e/nixos/modules/nixos/services/adguardhome/default.nix#L139
  # add user, needed to access the secret
  users.users.${adguardUser} = {
    isSystemUser = true;
    group = adguardUser;
  };
  users.groups.${adguardUser} = {};
  # insert password before service starts
  # password in sops is unencrypted, so we bcrypt it
  # and insert it as per config requirements
  # Ref: https://github.com/AdguardTeam/AdGuardHome/wiki/Configuration#reset-web-password
  systemd.services.adguardhome = {
    preStart = lib.mkAfter ''
      HASH=$(cat ${config.sops.secrets.adguard-passwordFile.path} | ${pkgs.apacheHttpd}/bin/htpasswd -binBC 10 "" | cut -c 2-)
      ${pkgs.gnused}/bin/sed -i "s,ADGUARDPASS,$HASH," "$STATE_DIRECTORY/AdGuardHome.yaml"
    '';
    serviceConfig.User = adguardUser;
  };
}
