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
  name = "immich-kiosk";
}
// {
  networking.firewall.allowedTCPPorts = [ 3000 ];

  sops.secrets.immich-kiosk-api-key = {
    sopsFile = ./secrets/immich-kiosk.yaml;
  };

  services.immich-kiosk = {
    enable = true;
    openFirewall = true;
    settings = {
      immich_url = "http://10.223.27.125:2283";
      immich_external_url = "https://immich.home.hyshka.com";
      immich_api_key._secret = config.sops.secrets.immich-kiosk-api-key.path;
      kiosk = {
        port = 3000;
      };
      # Additional configuration can be added here
      # See https://docs.immichkiosk.app/configuration/ for available options
      # Examples:
      # duration = 30;
      # layout = "splitview";
      # disable_ui = true;
      # albums = [
      #   "album-id-1"
      #   "album-id-2"
      # ];
    };
  };
}
