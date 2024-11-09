{
  pkgs,
  lib,
  config,
  ...
}: {
  users.users.hyshka = {
    home = "/Users/hyshka";
    description = "Bryan Hyshka";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = lib.splitString "\n" (builtins.readFile ../../home/hyshka/ssh.pub);
    packages = [pkgs.home-manager];
  };

  #home-manager.users.hyshka = import ../../home/hyshka/${config.networking.hostName}.nix;
}
