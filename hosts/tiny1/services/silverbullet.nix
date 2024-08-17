{config, ...}: {
  sops.secrets.silverbullet-envFile = {};

  services.silverbullet = {
    enable = true;
    spaceDir = "/mnt/storage/silverbullet";
    listenPort = 3010;
    listenAddress = "127.0.0.1";
    envFile = config.sops.secrets.silverbullet-envFile.path;
  };
}
