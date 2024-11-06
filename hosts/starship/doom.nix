{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    zandronum
    zandronum-server
    doomseeker
  ];
}
