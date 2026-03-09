{
  pkgs,
  lib,
  inputs,
  outputs,
  ...
}:
let
  container = import ./default.nix { inherit lib inputs; };
in
{
  imports = [
    (container.mkContainer { name = "upsnap"; })
    outputs.nixosModules.upsnap
  ];

  services.upsnap = {
    enable = true;
    openFirewall = true;
    package = inputs.nur.legacyPackages."${pkgs.stdenv.hostPlatform.system}".repos.someron.pkgs.upsnap;
    host = "0.0.0.0";
  };
}
