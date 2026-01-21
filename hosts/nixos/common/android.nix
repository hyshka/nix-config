{ pkgs, ... }:
{
  users.users.hyshka.extraGroups = [ "adbusers" ];
  environment.systemPackages = [ pkgs.android-tools ];
}
