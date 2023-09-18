{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ psitransfer ];

  sops.secrets = {
    psitransfer_password = {};
  };

  # TODO replace with microbin
  # https://github.com/szabodanika/microbin
  services.psitransfer = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = 3000;
      uploadDirectory = "/mnt/storage/psitransfer";
      uploadPasswordFile = config.sops.secrets.psitransfer_password.path;
  };
}
