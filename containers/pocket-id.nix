{
  config,
  lib,
  inputs,
  ...
}:
let
  container = import ./default.nix { inherit lib inputs; };
in
container.mkContainer {
  name = "pocket-id";
}
// {
  networking.firewall.allowedTCPPorts = [ 1411 ];

  sops.secrets.pocket-id-encryption-key = {
    sopsFile = ./secrets/pocket-id.yaml;
    owner = config.services.pocket-id.user;
    group = config.services.pocket-id.group;
  };

  services.pocket-id = {
    enable = true;
    settings = {
      APP_URL = "https://auth.home.hyshka.com";
      TRUST_PROXY = true;
      ANALYTICS_DISABLED = true;
    };
    environmentFile = config.sops.secrets.pocket-id-encryption-key.path;
  };
}
