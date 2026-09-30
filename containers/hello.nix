{
  lib,
  inputs,
  pkgs,
  ...
}:
let
  container = import ./default.nix { inherit lib inputs; };
in
{
  imports = [
    (container.mkContainer { name = "hello"; })
  ];
  environment.systemPackages = [
    pkgs.hello
    #pkgs.fortune
  ];
}
