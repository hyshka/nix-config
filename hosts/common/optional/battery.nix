{
  hardware.intel-gpu-tools.enable = true;
  powerManagement.powertop.enable = true;
  powerManagement.cpuFreqGovernor = "schedutil";
  hardware.system76.power-daemon.enable = true;

  #services.system76-scheduler.settings.cfsProfiles.enable = true;
  #services.thermald.enable = true; # only useful for intel
}
