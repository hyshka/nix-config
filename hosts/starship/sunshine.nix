{...}: {
  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true;
  };

  services.avahi = {
    enable = true;
    reflector = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      userServices = true;
      workstation = true;
    };
  };
}
