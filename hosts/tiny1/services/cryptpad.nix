{
  inputs,
  pkgs,
  ...
}: {
  # TODO: Force due to removed module in 24.05
  # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/rename.nix#L113
  disabledModules = [
    "rename.nix"
  ];
  # TODO cryptpad module only available in unstable
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/web-apps/cryptpad.nix"
  ];
  # Override package lookup from module with unstable
  nixpkgs.config = {
    packageOverrides = {
      cryptpad = pkgs.unstable.cryptpad;
    };
  };

  services.cryptpad = {
    enable = true;
    settings = {
      httpPort = 3006;
      httpUnsafeOrigin = "https://cryptpad.home.hyshka.com";
      httpSafeOrigin = "https://cryptpad-ui.home.hyshka.com";
      websocketPort = 3003; # default
      adminKeys = []; # TODO
    };
  };
}
