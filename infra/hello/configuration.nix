{
  pkgs,
  ...
}:
{
  environment.systemPackages = [
    pkgs.hello
    #pkgs.fortune
  ];
}
