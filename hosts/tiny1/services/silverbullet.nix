{config, ...}: {
  sops.secrets.silverbullet-envFile = {};

  services.silverbullet = {
    enable = true;
    spaceDir = "/mnt/storage/silverbullet";
    listenPort = 3010;
    listenAddress = "0.0.0.0";
    envFile = config.sops.secrets.silverbullet-envFile.path;
  };
}
