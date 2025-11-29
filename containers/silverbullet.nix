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
  name = "silverbullet";
}
// {
  networking.firewall.allowedTCPPorts = [ 3000 ];
  sops.secrets.environmentFile = {
    sopsFile = ./secrets/silverbullet.yaml;
  };

  virtualisation.oci-containers.containers.silverbullet = {
    image = "ghcr.io/silverbulletmd/silverbullet:2.3.0";
    ports = [ "0.0.0.0:3000:3000" ];
    volumes = [ "/var/lib/silverbullet:/space" ];
    environmentFiles = [ config.sops.secrets.environmentFile.path ];
  };
}
