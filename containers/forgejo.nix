{
  lib,
  inputs,
  ...
}:
let
  container = import ./default.nix { inherit lib inputs; };
in
{
  imports = [ (container.mkContainer { name = "forgejo"; }) ];

  # Git-over-SSH is served by Forgejo's built-in SSH server (no openssh needed).
  # Expose it from the host once the container has its static IP:
  #   incus config device add forgejo ssh-proxy proxy \
  #     listen=tcp:0.0.0.0:2222 connect=tcp:10.223.27.X:2222
  networking.firewall.allowedTCPPorts = [
    3000
    2222
  ];

  services.forgejo = {
    enable = true;
    dump.enable = true;

    settings = {
      server = {
        DOMAIN = "forgejo.home.hyshka.com";
        ROOT_URL = "https://forgejo.home.hyshka.com/";

        # Built-in SSH server for git clone/push over SSH.
        START_SSH_SERVER = true;
        SSH_DOMAIN = "forgejo.home.hyshka.com";
        SSH_PORT = 2222;
        SSH_LISTEN_PORT = 2222;
      };

      service.DISABLE_REGISTRATION = true;
      session.COOKIE_SECURE = true;

      # Forgejo Actions (the build runner connects to this instance).
      actions.ENABLED = true;
      repository.DEFAULT_REPO_UNITS = "repo.code,repo.issues,repo.pulls,repo.actions,repo.releases,repo.wiki";

      # Small instance: a size-limited LRU cache instead of the 50k-item default.
      # https://forgejo.org/docs/latest/admin/config-cheat-sheet/#cache-cache
      cache = {
        ADAPTER = "twoqueue";
        HOST = ''{"size":100, "recent_ratio":0.25, "ghost_ratio":0.5}'';
      };
    };
  };

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/forgejo"
    ];
  };
}
