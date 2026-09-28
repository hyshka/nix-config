{
  config,
  lib,
  inputs,
  ...
}:
let
  container = import ./default.nix { inherit lib inputs; };
in
{
  imports = [ (container.mkContainer { name = "forgejo-build-runner"; }) ];

  # Bootstrap with nesting so podman can run job containers:
  #   ./incus-manager.sh bootstrap forgejo-build-runner --nesting
  #
  # One-time registration (repository scope is the tightest):
  #   <repo> -> Settings -> Actions -> Runners -> Create new runner
  # Then:
  #   1. sops containers/secrets/forgejo-build-runner.yaml   # replace the token placeholder
  #   2. set settings.server.connections.default.uuid below to the runner UUID
  #
  # The runner needs https://forgejo.home.hyshka.com/ (caddy + DNS) to be live first.

  virtualisation.podman.enable = true;

  sops.secrets.forgejo-build-runner-token = {
    sopsFile = ./secrets/forgejo-build-runner.yaml;
  };

  services.forgejo-runner.instances.build = {
    enable = true;

    settings = {
      runner.labels = [
        # Closest thing to a GitHub-hosted ubuntu runner (~550 MiB compressed)
        "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-24.04"
      ];

      server.connections.default = {
        url = "https://forgejo.home.hyshka.com/";
        uuid = "REPLACE_WITH_REGISTRATION_UUID";
      };

      # Cap job containers. Keep the safe defaults for privileged/network/valid_volumes.
      container.options = "--memory=2g --cpus=2";
    };

    secrets.server.connections.default.token_url = config.sops.secrets.forgejo-build-runner-token.path;
  };

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/forgejo-runner"
      "/var/lib/containers" # podman image cache; drop if you want it re-pulled each boot
    ];
  };
}
