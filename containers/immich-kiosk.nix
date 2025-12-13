{
  pkgs,
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
    owner = "immich-kiosk";
    group = "immich-kiosk";
  };

  # Create the user
  users.users.immich-kiosk = {
    isSystemUser = true;
    group = "immich-kiosk";
  };

  users.groups.immich-kiosk = { };

  # NOTE: ._secret syntax is not playing well with DynamicUser
  # /1__run_secrets_immich-kiosk-api-key error in pre start script
  # missing systemd CREDENTIALS_DIRECTORY env var in ExecStart
  systemd.services.immich-kiosk.serviceConfig = {
    DynamicUser = lib.mkForce false;
    Environment = [
      "KIOSK_IMMICH_API_KEY_FILE=${config.sops.secrets.immich-kiosk-api-key.path}"
    ];
  };

  services.immich-kiosk = {
    enable = true;
    openFirewall = true;
    settings = {
      immich_url = "http://10.223.27.125:2283";
      immich_external_url = "https://immich.home.hyshka.com";
      kiosk = {
        port = 3000;
        behind_proxy = true;
      };
      albums = [
        "9ae37cca-25b8-47b2-bd58-8c871993e4b7"
      ];
      # Additional configuration can be added here
      # See https://docs.immichkiosk.app/configuration/ for available options
      # Examples:
      # duration = 30;
      # layout = "splitview";
      # disable_ui = true;
    };
  };
}
