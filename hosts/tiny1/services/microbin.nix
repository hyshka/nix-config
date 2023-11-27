{
  config,
  pkgs,
  ...
}: {
  imports = [
    "${pkgs.unstable}/nixos/modules/services/web-apps/microbin.nix"
  ];

  services.microbin = {
    enable = true;
    passwordFile = config.sops.secrets.microbin-passwordFile;
    dataDir = "/mnt/storage/microbin";
    # TODO https://microbin.eu/docs/installation-and-configuration/configuration/
    settings = {
      MICROBIN_PORT = 8081;
    };
  };

  sops.secrets.microbin-passwordFile = {};
}
