{
  config,
  lib,
  inputs,
  ...
}:
let
  container = import ./default.nix { inherit lib inputs; };
in
{
  imports = [ (container.mkContainer { name = "ntfy"; }) ];

  # Proxy ports from host to container: incus config device add ntfy tcp_proxy proxy listen=tcp:0.0.0.0:2586 connect=tcp:10.223.27.234:2586

  networking.firewall.allowedTCPPorts = [
    2586
    9091
  ];

  sops.secrets."environment_file" = {
    sopsFile = ./secrets/ntfy.yaml;
    owner = config.services.ntfy-sh.user;
    group = config.services.ntfy-sh.group;
  };

  services.ntfy-sh = {
    enable = true;
    environmentFile = config.sops.secrets."environment_file".path;
    settings = {
      base-url = "https://ntfy.home.hyshka.com";
      behind-proxy = true;
      listen-http = "0.0.0.0:2586";
      log-format = "json";
      log-file = "/var/log/ntfy/ntfy.log";
      metrics-listen-http = "0.0.0.0:9091";
      cache-file = "/var/lib/ntfy-sh/cache-file.db"; # persist messages across reboots
      auth-default-access = "deny-all";
      # Auth user-file, auth-users, auth-tokens condifured in environment_file
    };
  };

  systemd.services.ntfy-sh.serviceConfig = {
    LogsDirectory = [ "ntfy" ];
  };

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/private/ntfy-sh"
    ];
  };
}
