{
  config,
  ...
}:
{
  # A full VM, so podman can run job containers without LXC nesting.

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
        url = "https://code.home.hyshka.com/";
        uuid = "f265f0e9-a15d-498b-ae84-9a54ad70e180";
      };

      # Cap job containers. Keep the safe defaults for privileged/network/valid_volumes.
      container.options = "--memory=2g --cpus=2";
    };

    secrets.server.connections.default.token_url = config.sops.secrets.forgejo-build-runner-token.path;
  };

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/forgejo-runner"
      "/var/lib/containers" # podman image cache
    ];
  };
}
