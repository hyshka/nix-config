{
  # Configuration for using a remote Nix builder over SSH.
  # See https://wiki.nixos.org/wiki/Distributed_build

  # TODO: how to automate the following steps?
  # ssh-keygen -f /root/.ssh/nixremote
  # copy /root/.ssh/nixremote.pub to ~nixremote/.ssh/authorized_keys on the remote host
  # add remotes ssh host key to local known_hosts, or set StrictHostKeyChecking accept-new
  # test ssh: sudo ssh -o IdentitiesOnly=yes -i /root/.ssh/nixremote -l nixremote builder
  # expect: login, but then This account is currently not available.
  programs.ssh = {
    extraConfig = ''
      Host builder
        # Prevent using ssh-agent or another keyfile, useful for testing
        IdentitiesOnly yes
        IdentityFile /root/.ssh/nixremote
        # The weakly privileged user on the remote builder – if not set, 'root' is used – which will hopefully fail
        User nixremote
    '';
    knownHosts = {
      builder.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJXvu9Tna0YHj3xY52qE66z+udZzs6SqW9gRZw2ADKUz root@tiny1";
    };
  };

  nix.buildMachines = [
    {
      hostName = "builder";
      system = "x86_64-linux";
      # Avoids "trusted-users" pain
      protocol = "ssh-ng";
      # default is 1 but may keep the builder idle in between builds
      maxJobs = 3;
      # how fast is the builder compared to your local machine
      speedFactor = 2;
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      mandatoryFeatures = [ ];
    }
  ];
  # required, otherwise remote buildMachines above aren't used
  nix.distributedBuilds = true;
  # optional, useful when the builder has a faster internet connection than yours
  nix.settings = {
    builders-use-substitutes = true;
  };
}
