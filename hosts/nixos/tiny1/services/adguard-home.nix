{
  config,
  pkgs,
  lib,
  ...
}:
let
  adguardUser = "adguardhome";
in
{
  networking.firewall.interfaces.enp0s31f6.allowedUDPPorts = [ 53 ];
  networking.firewall.interfaces.tailscale0.allowedUDPPorts = [ 53 ];

  # user_rules, blocked_services, and clients are managed imperatively via the AdGuard Home UI
  services.adguardhome = {
    enable = true;
    host = "0.0.0.0";
    port = 3020;
    allowDHCP = true;
    settings = {
      schema_version = 32;
      http = {
        address = "0.0.0.0:${toString config.services.adguardhome.port}";
      };
      users = [
        {
          name = "admin";
          password = "ADGUARDPASSWORD_PLACEHOLDER";
        }
      ];
      auth_attempts = 15;
      dns = {
        bind_hosts = [
          "127.0.0.1"
          "::1"
          "192.168.1.200"
          "fe80::6e4b:90ff:fe4f:b69c%enp0s31f6"
          "100.116.243.20"
          "fd7a:115c:a1e0::baf4:f314%tailscale0"
        ];
        bootstrap_dns = [
          "9.9.9.9"
          "149.112.112.112"
          "2620:fe::fe"
          "2620:fe::9"
        ];
        upstream_dns = [
          "https://dns.quad9.net/dns-query"
          "tls://dns.quad9.net"
        ];
        ratelimit = 0;
        trusted_proxies = [
          "10.223.27.64/32"
          "127.0.0.0/8"
          "::1/128"
        ];
        enable_dnssec = true;
        cache_optimistic = true;
      };
      querylog = {
        interval = "168h";
      };
      filters = [
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
          name = "AdGuard DNS filter";
          id = 1;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
          name = "AdAway Default Blocklist";
          id = 2;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_59.txt";
          name = "AdGuard DNS Popup Hosts filter";
          id = 1758500752;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_53.txt";
          name = "AWAvenue Ads Rule";
          id = 1758500753;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_4.txt";
          name = "Dan Pollock's List";
          id = 1758500754;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_51.txt";
          name = "HaGeZi's Pro++ Blocklist";
          id = 1758500755;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_27.txt";
          name = "OISD Blocklist Big";
          id = 1758500756;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_3.txt";
          name = "Peter Lowe's Blocklist";
          id = 1758500757;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_33.txt";
          name = "Steven Black's List";
          id = 1758500758;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_30.txt";
          name = "Phishing URL Blocklist (PhishTank and OpenPhish)";
          id = 1758500759;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_12.txt";
          name = "Dandelion Sprout's Anti-Malware List";
          id = 1758500760;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_54.txt";
          name = "HaGeZi's DynDNS Blocklist";
          id = 1758500761;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_55.txt";
          name = "HaGeZi's Badware Hoster Blocklist";
          id = 1758500762;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_56.txt";
          name = "HaGeZi's The World's Most Abused TLDs";
          id = 1758500763;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_44.txt";
          name = "HaGeZi's Threat Intelligence Feeds";
          id = 1758500764;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_8.txt";
          name = "NoCoin Filter List";
          id = 1758500765;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_10.txt";
          name = "Scam Blocklist by DurableNapkin";
          id = 1758500766;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_18.txt";
          name = "Phishing Army";
          id = 1758500767;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_42.txt";
          name = "ShadowWhisperer's Malware List";
          id = 1758500768;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_31.txt";
          name = "Stalkerware Indicators List";
          id = 1758500769;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt";
          name = "The Big List of Hacked Malware Web Sites";
          id = 1758500770;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_50.txt";
          name = "uBlock₀ filters – Badware risks";
          id = 1758500771;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt";
          name = "Malicious URL Blocklist (URLHaus)";
          id = 1758500772;
        }
      ];
      whitelist_filters = [
        {
          enabled = true;
          url = "https://badblock.celenity.dev/abp/whitelist.txt";
          name = "BadBlock - Whitelist (ABP)";
          id = 1758500773;
        }
        {
          enabled = true;
          url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/whitelist-urlshortener.txt";
          name = "HaGeZi's URL Shorteners";
          id = 1758500774;
        }
      ];
    };
  };

  users.users.${adguardUser} = {
    isSystemUser = true;
    group = adguardUser;
  };
  users.groups.${adguardUser} = { };

  sops.secrets.adguard-passwordFile = {
    owner = adguardUser;
    group = adguardUser;
  };

  systemd.services.adguardhome = {
    serviceConfig.User = adguardUser;
    preStart = lib.mkAfter ''
      if [ -f "${config.sops.secrets.adguard-passwordFile.path}" ]; then
        PASSWORD_HASH=$(cat "${config.sops.secrets.adguard-passwordFile.path}")
        sed "s|ADGUARDPASSWORD_PLACEHOLDER|$PASSWORD_HASH|g" "$STATE_DIRECTORY/AdGuardHome.yaml" > "$STATE_DIRECTORY/AdGuardHome.yaml.tmp"
        mv "$STATE_DIRECTORY/AdGuardHome.yaml.tmp" "$STATE_DIRECTORY/AdGuardHome.yaml"
      fi
    '';
  };
}
