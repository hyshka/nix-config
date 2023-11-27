{
  inputs,
  config,
  pkgs,
  ...
}: {
  # Disable module in case an older version creeps into stable
  disabledModules = [
    "services/web-apps/microbin.nix"
  ];
  # Import nixos module from unstable
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/web-apps/microbin.nix"
  ];
  # Override package lookup from module with unstable
  nixpkgs.config = {
    packageOverrides = {
      microbin = pkgs.unstable.microbin;
    };
  };

  services.microbin = {
    enable = true;
    passwordFile = config.sops.secrets.microbin-passwordFile.path;
    dataDir = "/mnt/storage/microbin/";
    # TODO https://microbin.eu/docs/installation-and-configuration/configuration/
    settings = {
      MICROBIN_PORT = 8081;
      #MICROBIN_DATA_DIR = "microbin_";
    };
  };

  sops.secrets.microbin-passwordFile = {};
}
