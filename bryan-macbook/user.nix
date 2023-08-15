{ inputs, pkgs, ... }:
let
  username = "hyshka";
in
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    home = "/Users/${username}";
    description = username;
    shell = pkgs.zsh;
  };

  nix.settings.trusted-users = [ username ];
}
