{
  #config,
  lib,
  inputs,
  ...
}: let
  container = import ./default.nix {inherit lib inputs;};
in
  container.mkContainer {
    name = "silverbullet";
  }
  // {
    networking.firewall.allowedTCPPorts = [3000];
    #sops.secrets.secretsFile = {
    #    sopsFile = ./secrets/silverbullet.yaml;
    #};

    virtualisation.oci-containers.containers.silverbullet = {
      image = "ghcr.io/silverbulletmd/silverbullet:v2";
      ports = ["0.0.0.0:3000:3000"];
      volumes = ["/var/lib/silverbullet:/space"];
      #environmentFiles = [config.sops.secrets.secretsFile.path];
    };

    # First run
    # incus create nixos/custom/silverbullet silverbullet -c security.nesting=true
    # sudo mkdir /persist/microvms/silverbullet && incus config device add silverbullet persist disk source=/persist/microvms/silverbullet path=/persist shift=true
    # incus storage volume create storage silverbullet_data
    # incus storage volume attach storage silverbullet_data silverbullet /var/lib/silverbullet
    # incus start silverbullet --console
    # incus config device override silverbullet eth0 ipv4.address=10.223.27.35

    # TODO:
    # nix-shell -p ssh-to-age --run 'sudo cat /persist/microvms/silverbullet/etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
  }
