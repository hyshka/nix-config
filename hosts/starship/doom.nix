{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    zandronum
    zandronum-server
    doomseeker
    fluidsynth
  ];
  networking.firewall.allowedUDPPorts = [10666];
}
