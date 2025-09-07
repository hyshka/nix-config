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
    # 2. Create container: ./incus-manager.sh create calibre --nesting
    # 3. On host machine, sudo mkdir /persist/microvms/calibre
    # 4. Add persist disk for media: ./incus-manager.sh add-persist-disk calibre
    # 5. Add data storage: incus config device add calibre data disk source=/mnt/storage/mediacenter/media/books/ path=/mnt/books/ raw.mount.options=idmap=b:998:0:1
    # 6. Set raw.idmap: incus config set calibre raw.idmap='both 0 998'
    # 7. Start container: incus start calibre --console
    # 8. Configure static ip: ./incus-manager.sh set-ip calibre
    # 9. Compute age key: ./incus-manager.sh get-age-key calibre
    # 10. Update nix-config with static IP and age key, then run: ./incus-manager.sh deploy calibre

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
      group = config.services.calibre-server.group;
    };

    services.calibre-server = {
      enable = true;
      port = 8083;
      openFirewall = true;
      host = "0.0.0.0";
      auth = {
        mode = "basic";
        enable = true;
        userDb = config.sops.secrets."calibre-users.sqlite".path;
      };
      libraries = [
        "/mnt/books"
      ];
    };
  }
