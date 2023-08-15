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

  # home manager
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = inputs;
  home-manager.users.hyshka = import ./home;
}
