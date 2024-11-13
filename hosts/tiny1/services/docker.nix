{pkgs, ...}: {
  # TODO: remove once services are migrated to nix
  environment.systemPackages = with pkgs; [docker-compose];

  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";
}
