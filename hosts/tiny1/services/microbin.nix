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

  sops.secrets.microbin-passwordFile = {};

  services.microbin = {
    enable = true;
    passwordFile = config.sops.secrets.microbin-passwordFile.path;
    dataDir = "/mnt/storage/microbin/";
    settings = {
      MICROBIN_PORT = 8081;
      MICROBIN_BIND = "127.0.0.1";
      MICROBIN_PUBLIC_PATH = "https://microbin.hyshka.com/";
      MICROBIN_MAX_FILE_SIZE_UNENCRYPTED_MB = 1024;
    };
  };

  services.ddclient.domains = ["microbin"];
  services.nginx.virtualHosts."microbin.hyshka.com" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:8081";
    };
    extraConfig = ''
      client_max_body_size 1024M;
    '';
  };
}
