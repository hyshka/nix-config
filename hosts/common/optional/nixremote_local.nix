{
  # Configuration for using a remote Nix builder over SSH.
  # See https://wiki.nixos.org/wiki/Distributed_build
  # TODO: how to automate the following steps?
  # ssh-keygen -f /root/.ssh/nixremote
  # copy /root/.ssh/nixremote.pub to ~nixremote/.ssh/authorized_keys on the remote host
  # add remotes ssh host key to local known_hosts, or set StrictHostKeyChecking accept-new
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
}
