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
  name = "pinchflat";
}
// {
  sops.secrets.secretsFile = {
    sopsFile = ./secrets/pinchflat.yaml;
  };

  # Create mediacenter group matching host GID for storage access
  users.groups.mediacenter = {
    gid = 13000;
  };

  services.pinchflat = {
    enable = true;
    port = 8945;
    openFirewall = true;
    group = "mediacenter";
    mediaDir = "/downloads";
    secretsFile = config.sops.secrets.secretsFile.path;
    extraConfig = {
      ENABLE_PROMETHEUS = "true";
    };
  };

  # Add pinchflat user to mediacenter group
  users.users.pinchflat.extraGroups = [ "mediacenter" ];

  # Persist Pinchflat data
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/pinchflat"
    ];
  };
}
