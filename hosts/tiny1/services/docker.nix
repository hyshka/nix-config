{pkgs, ...}: {
  environment.systemPackages = with pkgs; [docker-compose];

  virtualisation = {
    docker.enable = true;
    oci-containers = {
      backend = "docker";
    };
  };
}
