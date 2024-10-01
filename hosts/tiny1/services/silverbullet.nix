{
  config,
  pkgs,
  ...
}: {
  sops.secrets.silverbullet-envFile = {};

  services.silverbullet = {
    enable = true;
    package = pkgs.unstable.silverbullet;
    spaceDir = "/mnt/storage/silverbullet";
    listenPort = 3010;
    listenAddress = "127.0.0.1";
    envFile = config.sops.secrets.silverbullet-envFile.path;
  };
}
