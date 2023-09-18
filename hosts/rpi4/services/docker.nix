{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ docker-compose ];

  # TODO split up
  virtualisation = {
      docker.enable = true;
      oci-containers = {
              backend = "docker";
              containers = {
	          dashy = {
                      image = "lissy93/dashy";
                      autoStart = false;
                      ports = [ "127.0.0.1:8888:80" ];
                      volumes = [
                              "/home/hyshka/dashy-conf.yml:/app/public/conf.yml"
                      ];
                      environment = {};
		  };
	          homepage = {
                      image = "ghcr.io/benphelps/homepage";
                      autoStart = true;
                      ports = [ "127.0.0.1:3001:3000" ];
                      volumes = [
		              # TODO write config with nix
		              "/home/hyshka/homepage-conf:/app/config"
       			      "/var/run/docker.sock:/var/run/docker.sock" # (optional) For docker integrations
                      ];
                      environment = {};
		  };
              };
      };
  };
}
