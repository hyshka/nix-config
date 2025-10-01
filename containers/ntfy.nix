{
  config,
  lib,
  inputs,
  ...
}:
let
  container = import ./default.nix { inherit lib inputs; };
in
container.mkContainer {
  name = "ntfy";
}
// {
  # Set up steps
  # 1. Import image to Incus: ./incus-manager.sh import ntfy
  # 2. Create container: ./incus-manager.sh create ntfy
  # 3. Add persist disk: ./incus-manager.sh add-persist-disk ntfy
  # 4. Start container: incus start ntfy --console
  # 5. Configure static ip: ./incus-manager.sh set-ip ntfy
  # 6. Compute age key: ./incus-manager.sh get-age-key ntfy
  # 7. Update nix-config with static IP and age key, then run: ./incus-manager.sh deploy ntfy
  # 8. Proxy ports from host to container: incus config device add ntfy tcp_proxy proxy listen=tcp:0.0.0.0:2586 connect=tcp:10.223.27.234:2586

  networking.firewall.allowedTCPPorts = [
    2586
    9091
  ];

  sops.secrets."ntfy_user.db" = {
    sopsFile = ./secrets/ntfy_user.db;
    format = "binary";
    owner = config.services.ntfy-sh.user;
    group = config.services.ntfy-sh.group;
    mode = "0600";
  };

  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://ntfy.home.hyshka.com";
      behind-proxy = true;
      # bind to all interfaces to receive connections from Docker containers
      listen-http = "0.0.0.0:2586";
      log-format = "json";
      log-file = "/var/log/ntfy/ntfy.log";
      metrics-listen-http = "0.0.0.0:9091";
      auth-file = config.sops.secrets."ntfy_user.db".path;
      auth-default-access = "deny-all";
    };
  };

  systemd.services.ntfy-sh.serviceConfig = {
    LogsDirectory = [ "ntfy" ];
  };
}
