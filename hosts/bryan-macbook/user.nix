{
  pkgs,
  lib,
  ...
}: {
  users.users.hyshka = {
    home = "/Users/hyshka";
    description = "hyshka";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = lib.splitString "\n" (builtins.readFile ../../../../home/hyshka/ssh.pub);
  };

  nix.settings.trusted-users = ["hyshka"];
}
