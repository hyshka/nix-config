{
  config,
  lib,
  inputs,
  ...
}: let
  container = import ./default.nix {inherit lib inputs;};
in
  container.mkContainer {
    name = "calibre";
  }
  // {
    # Set up steps
    # 1. Import image to Incus: ./incus-manager.sh import calibre
    # 2. Create container: ./incus-manager.sh create calibre
    # 3. Add persist disk for media: ./incus-manager.sh add-persist-disk calibre
    # 4. Start container: incus start calibre --console
    # 5. Configure static ip: ./incus-manager.sh set-ip calibre
    # 6. Compute age key: ./incus-manager.sh get-age-key calibre
    # 7. Update nix-config with static IP and age key, then run: ./incus-manager.sh deploy calibre

    # To generate user db:
    # 1. Run calibre-server with auth disabled
    # 2. Then, generate a users database:
    #    calibre-server --userdb ./calibre-users.sqlite --manage-users
    # 3. Finally, encrypt the binary as a secret:
    #    sops -e ./calibre-users.sqlite > containers/secrets/calibre-users.sqlite

    sops.secrets."calibre-users.sqlite" = {
      sopsFile = ./secrets/calibre-users.sqlite;
      format = "binary";
      owner = config.services.calibre-server.user;
    };

    services.calibre-server = {
      enable = true;
      port = 8083;
      # Need to listen on all interfaces for Readarr and koreader
      host = "0.0.0.0";
      auth = {
        mode = "basic";
        enable = true;
        userDb = config.sops.secrets."calibre-users.sqlite".path;
      };
      libraries = [
        "/mnt/storage/mediacenter/media/books"
      ];
    };

    # Open port to sync with koreader
    networking.firewall.allowedTCPPorts = [8083];
  }
