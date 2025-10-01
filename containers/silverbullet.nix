{
  #config,
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
  #sops.secrets.secretsFile = {
  #    sopsFile = ./secrets/silverbullet.yaml;
  #};

  virtualisation.oci-containers.containers.silverbullet = {
    image = "ghcr.io/silverbulletmd/silverbullet:2.1.5";
    ports = [ "0.0.0.0:3000:3000" ];
    volumes = [ "/var/lib/silverbullet:/space" ];
    #environmentFiles = [config.sops.secrets.secretsFile.path];
  };
}
