{
  lib,
  inputs,
  ...
}:
let
  container = import ./default.nix { inherit lib inputs; };
in
container.mkContainer {
  name = "cryptpad";
}
// {
  networking.firewall.allowedTCPPorts = [
    3003
    3006
  ];
  services.cryptpad = {
    enable = true;
    settings = {
      dataRoot = "/mnt/cryptad";
      httpAddress = "0.0.0.0";
      httpPort = 3006;
      httpUnsafeOrigin = "https://cryptpad-sandbox.home.hyshka.com";
      httpSafeOrigin = "https://cryptpad.home.hyshka.com";
      websocketPort = 3003;
    };
  };
}
