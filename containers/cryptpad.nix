{
  config,
  lib,
  inputs,
  ...
}: let
  container = import ./default.nix {inherit lib inputs;};
in
  container.mkContainer {
    name = "cryptpad";
  }
  // {
    # Set up steps
    # 1. Deploy image to Incus
    # 2. Create container: incus create nixos/custom/cryptpad cryptpad -c security.nesting=true
    # 3. Add persist disk: incus config device add cryptpad persist disk source=/persist/microvms/cryptpad path=/persist shift=true
    # 4. Start container: incus start cryptpad --console
    # 5. Configure static ip: Grab IPv4 from incus list, then incus config device override cryptpad eth0 ipv4.address=<IP>
    # 6. Compute age key: nix-shell -p ssh-to-age --run 'sudo cat /persist/microvms/cryptpad/etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
    # 7. Update nix-config with static IP and age key, rebuild the image

    networking.firewall.allowedTCPPorts = [3003 3006];

    sops.secrets.cryptpad_admin_keys = {
      sopsFile = ./secrets/cryptpad.yaml;
      owner = config.services.cryptpad.user;
      group = config.services.cryptpad.group;
    };

    services.cryptpad = {
      enable = true;
      settings = {
        dataRoot = "/mnt/cryptad";
        httpAddress = "0.0.0.0";
        httpPort = 3006;
        httpUnsafeOrigin = "https://cryptpad.home.hyshka.com";
        httpSafeOrigin = "https://cryptpad-ui.home.hyshka.com";
        websocketPort = 3003;
        adminKeysFile = config.sops.secrets.cryptpad_admin_keys.path;
      };
    };
  }
