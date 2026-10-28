{
  nixosImages.openchamber = {
    configuration = ./configuration.nix;
    remote = "starship";
  };

  resource.incus_instance.openchamber = {
    depends_on = [ "incus_storage_volume.openchamber-persist" ];
    config = {
      "raw.idmap" = "both 0 0";
      "security.nesting" = "true";
    };
    device = [
      {
        name = "web";
        type = "proxy";
        properties = {
          listen = "tcp:0.0.0.0:8888";
          connect = "tcp:127.0.0.1:3000";
        };
      }
      {
        name = "sops-age-key";
        type = "disk";
        properties = {
          source = "/run/incus-secrets/lxc-ai-age-key";
          path = "/var/lib/sops-nix/key.txt";
          readonly = "true";
          "raw.mount.options" = "uid=0,gid=0";
        };
      }
      {
        name = "persist";
        type = "disk";
        properties = {
          pool = "default";
          source = "openchamber-persist";
          path = "/persist";
        };
      }
    ];
  };

  resource.incus_storage_volume."openchamber-persist" = {
    remote = "starship";
    name = "openchamber-persist";
    pool = "default";
    project = "lab-default";
    config."security.shifted" = "true";
    lifecycle.prevent_destroy = true;
  };
}
