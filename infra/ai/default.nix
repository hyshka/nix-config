{
  nixosImages.ai = {
    configuration = ./configuration.nix;
    remote = "starship";
    project = "lab-gpu";
  };

  resource.incus_instance.ai = {
    depends_on = [ "incus_storage_volume.ai-persist" ];
    config."raw.idmap" = "both 0 0";
    device = [
      {
        name = "persist";
        type = "disk";
        properties = {
          pool = "default";
          source = "ai-persist";
          path = "/persist";
        };
      }
      {
        name = "gpu";
        type = "gpu";
        properties = {
          pci = "0000:2b:00.0";
          gid = "303";
        };
      }
      {
        name = "kfd";
        type = "unix-char";
        properties = {
          source = "/dev/kfd";
          path = "/dev/kfd";
          gid = "303";
        };
      }
      {
        name = "open-webui";
        type = "proxy";
        properties = {
          listen = "tcp:0.0.0.0:8080";
          connect = "tcp:127.0.0.1:8080";
        };
      }
      {
        name = "ollama";
        type = "proxy";
        properties = {
          listen = "tcp:0.0.0.0:11434";
          connect = "tcp:127.0.0.1:11434";
        };
      }
    ];
  };

  resource.incus_storage_volume."ai-persist" = {
    remote = "starship";
    name = "ai-persist";
    pool = "default";
    project = "lab-gpu";
    config."security.shifted" = "true";
    lifecycle.prevent_destroy = true;
  };
}
