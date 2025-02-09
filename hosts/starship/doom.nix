{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    zandronum
    zandronum-server
    doomseeker
    fluidsynth
  ];
  networking.firewall.allowedTCPPorts = [10666];
}
