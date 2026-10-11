{
  config,
  ...
}:
{
  # A full VM, so podman can run job containers without LXC nesting.

  # Bootstrap:
  #   1. nix run .#apply
  #   2. generate the SSH host key + sops age key (see infra/virtual-machine.nix)
  #   3. <repo> -> Settings -> Actions -> Runners -> Create new runner
  #      (repository scope is the tightest)
  #   4. sops infra/forgejo-build-runner/secrets/forgejo-build-runner.yaml  # replace the token placeholder
  #   5. set settings.server.connections.default.uuid below to the runner UUID
  #      and re-run `nix run .#apply`
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
