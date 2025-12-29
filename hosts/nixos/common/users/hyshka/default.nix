{
  pkgs,
  config,
  lib,
  ...
}:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.mutableUsers = false;
  users.users.hyshka = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = ifTheyExist [
      "audio"
      "docker"
      "video"
      "wheel"
      "restic"
    ];

    openssh.authorizedKeys.keys = lib.splitString "\n" (
      builtins.readFile ../../../../../home/hyshka/ssh.pub
    );
    # hash password with `mkpasswd <mypassword>`
    hashedPasswordFile = config.sops.secrets.hyshka_password.path;
    packages = [ pkgs.home-manager ];
  };

  sops.secrets.hyshka_password = {
    sopsFile = ../../secrets.yaml;
    neededForUsers = true;
  };
}
